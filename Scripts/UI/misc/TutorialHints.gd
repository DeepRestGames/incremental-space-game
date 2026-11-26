extends Node

## Context-aware triggers for radio tips.

const TIP_MOVE := &"move"
const TIP_MINE := &"mine"
const TIP_MINE_SPAM := &"mine_spam"
const TIP_OXYGEN_LOW := &"oxygen_low"

@export_group("Messages")
# TODO: make programmatic (without hard coding commands)
@export var move_tip: String = "Use WASD to move."
@export var mine_tip: String = "Hold Left Click over a rock to mine it."
@export var mine_spam_tip: String = "HOLD Left Click / E to mine!"
@export var oxygen_low_tip: String = "Watch your oxygen! Head back to the ship before it runs out."

@export_group("Click Spam")
## Separate clicks within `spam_window` seconds that trigger `mine_spam_tip`.
@export var spam_clicks: int = 5
@export var spam_window: float = 2.5
## Holding mine this long proves the player knows holding works and retires the spam tip.
@export var hold_to_retire_sec: float = 1.0
## How long the player does what a tip asks before the banner zips away.
@export var action_dismiss_sec: float = 0.5

@export_group("Oxygen Warning")
@export_range(0.1, 0.9) var oxygen_warn_ratio: float = 0.5
## How many separate crossings below `oxygen_warn_ratio` show the radio tip.
@export var oxygen_warn_max_times: int = 2

var _tap_times: Array[float] = []
var _hold_duration: float = 0.0
var _was_above_oxygen_warn: bool = true
var _active_tip: StringName = &""
var _comply_time: float = 0.0
var _mined_during_tip: bool = false

@onready var idle_timer: Timer = %IdleTimer


func _ready() -> void:
	EventBus.player_movement.connect(_on_player_movement)
	EventBus.breakable_damaged.connect(_on_breakable_damaged)
	EventBus.update_oxygen_HUD.connect(_on_update_oxygen)
	EventBus.player_enter_expedition_return_area.connect(_on_enter_ship_return)
	idle_timer.timeout.connect(_on_idle_timeout)
	_arm_idle_timer()


func _arm_idle_timer() -> void:
	if GameManager.transitioning:
		await TransitionManager.finished
	# On expeditions, let the intro grace finish before counting the 5s.
	while GameManager.is_expedition_starting():
		await get_tree().process_frame
	idle_timer.start()


func _process(delta: float) -> void:
	if GameManager.is_world_obscured():
		return
	_update_active_tip_dismiss(delta)
	_update_click_spam(delta)


func _update_active_tip_dismiss(delta: float) -> void:
	var doing_action := false
	match _active_tip:
		TIP_MOVE:
			doing_action = Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
		TIP_MINE:
			doing_action = _mined_during_tip
	if doing_action:
		_comply_time += delta
		if _comply_time >= action_dismiss_sec:
			_dismiss_active_tip()


func _update_click_spam(delta: float) -> void:
	if not GameManager.expedition_started or GameManager.is_tip_retired(TIP_MINE_SPAM):
		return
	if GameManager.player and GameManager.player.inside_interactable_area:
		return

	if Input.is_action_pressed("interact"):
		_hold_duration += delta
		if _hold_duration >= hold_to_retire_sec:
			GameManager.retire_tip(TIP_MINE_SPAM)
			if _active_tip == TIP_MINE_SPAM:
				_dismiss_active_tip()
			return
	else:
		_hold_duration = 0.0

	if Input.is_action_just_pressed("interact"):
		var now: float = Time.get_ticks_msec() / 1000.0
		_tap_times.append(now)
		while not _tap_times.is_empty() and now - _tap_times[0] > spam_window:
			_tap_times.pop_front()
		if _tap_times.size() >= spam_clicks:
			_show_tip(TIP_MINE_SPAM, mine_spam_tip)


func _on_player_movement(direction: Vector2) -> void:
	# InputManager emits Vector2.ZERO on mouse moves too; only real WASD counts.
	if direction != Vector2.ZERO:
		GameManager.retire_tip(TIP_MOVE)


func _on_breakable_damaged(_damage: int, _is_crit: bool) -> void:
	GameManager.retire_tip(TIP_MINE)
	if _active_tip == TIP_MINE:
		_mined_during_tip = true


func _on_enter_ship_return() -> void:
	if _active_tip == TIP_OXYGEN_LOW:
		_dismiss_active_tip()


func _on_update_oxygen(current: float, max_val: float) -> void:
	if not GameManager.expedition_started or max_val <= 0.0:
		return
	var ratio: float = current / max_val
	if _was_above_oxygen_warn and ratio <= oxygen_warn_ratio:
		_show_tip(TIP_OXYGEN_LOW, oxygen_low_tip, oxygen_warn_max_times, true)
	_was_above_oxygen_warn = ratio > oxygen_warn_ratio


func _on_idle_timeout() -> void:
	if GameManager.is_world_obscured():
		idle_timer.start()
		return
	if not GameManager.is_tip_retired(TIP_MOVE):
		_show_tip(TIP_MOVE, move_tip)
	elif GameManager.expedition_started and not GameManager.is_tip_retired(TIP_MINE):
		_show_tip(TIP_MINE, mine_tip)


func _show_tip(tip_id: StringName, text: String, max_times: int = 1, urgent: bool = false) -> void:
	if GameManager.try_show_tip(tip_id, text, max_times, urgent):
		_active_tip = tip_id
		_comply_time = 0.0
		_mined_during_tip = false


func _dismiss_active_tip() -> void:
	_active_tip = &""
	EventBus.radio_dismiss.emit()
