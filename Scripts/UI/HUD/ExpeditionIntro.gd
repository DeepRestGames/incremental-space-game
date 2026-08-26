extends Control

## Opening beat of an expedition: the level name appears as noise and resolves
## character by character at irregular intervals, like a terminal readout, then
## holds and breaks back up into noise.
##
## Purely cosmetic and non-blocking: the player can already move and mine while
## it plays. The gameplay side of the grace period (oxygen not draining yet) is
## owned by GameManager.expedition_grace_remaining, NOT by this animation.
## Retiming anything here does not change when the countdown starts - for that,
## edit BaseValuesDB.EXPEDITION_GRACE_PERIOD.

## Glyphs used for the not-yet-resolved part of the name.
const SCRAMBLE_CHARS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#$%&/\\<>[]{}=+-*"

enum Phase { IDLE, BOOT, HOLD, GLITCH_OUT }

@export_group("Timing")
## How long the name takes to resolve out of the noise.
@export var boot_time: float = 0.9
## How long the resolved name stays up.
@export var hold_time: float = 1.3
## How long it breaks up before disappearing.
@export var glitch_out_time: float = 0.4

@export_group("Look")
@export_range(0.0, 1.0) var dim_alpha: float = 0.45
## How far the cyan chromatic ghost drifts at full instability, in pixels.
@export var ghost_offset: float = 3.0
## Max sideways jump of the panel at full instability, in pixels.
@export var jitter_strength: float = 4.0

@onready var dim: ColorRect = $Dim
@onready var center: CenterContainer = $Center
@onready var level_name_label: Label = $Center/TitlePanel/LevelName
@onready var ghost_label: Label = $Center/TitlePanel/LevelName/Ghost

var _phase: int = Phase.IDLE
var _elapsed: float = 0.0
var _full_text: String = ""
var _resolved: int = 0
var _next_resolve_at: float = 0.0


func _ready() -> void:
	# Hidden by default: the same HUD is instanced in the lobby, where there is
	# no expedition to introduce.
	visible = false
	set_process(false)

	if not GameManager.expedition_started:
		return

	_full_text = GameManager.get_selected_level_name()

	# The intro plays to the player, not to the back of a transition wipe. This
	# node is PROCESS_MODE_INHERIT, so it is frozen while the transition holds
	# the pause: starting now would show a static scramble until the reveal ends.
	if GameManager.transitioning:
		await TransitionManager.finished

	play_intro()


func play_intro() -> void:
	visible = true
	center.visible = true
	dim.color.a = 0.0

	_resolved = 0
	_enter_phase(Phase.BOOT)
	_apply_text(0)
	_apply_instability(1.0)
	set_process(true)

	# The screen dim fades smoothly and never flickers: strobing a full-screen
	# rect is unpleasant and a photosensitivity risk.
	var dim_tween := create_tween()
	dim_tween.tween_property(dim, "color:a", dim_alpha, 0.2)


func _process(delta: float) -> void:
	_elapsed += delta

	match _phase:
		Phase.BOOT:
			_process_boot()
		Phase.HOLD:
			_process_hold()
		Phase.GLITCH_OUT:
			_process_glitch_out()


func _process_boot() -> void:
	# Resolve a character or two at a time, at irregular intervals, so it reads
	# as a struggling readout rather than a smooth typewriter.
	if _resolved < _full_text.length() and _elapsed >= _next_resolve_at:
		_resolved += randi_range(1, 2)
		var average_step: float = boot_time / float(max(_full_text.length(), 1))
		_next_resolve_at = _elapsed + randf_range(average_step * 0.3, average_step * 1.7)

	_apply_text(_resolved)

	# The panel settles as the text resolves.
	var progress: float = clampf(_elapsed / max(boot_time, 0.01), 0.0, 1.0)
	_apply_instability(1.0 - progress)

	if _resolved >= _full_text.length():
		_enter_phase(Phase.HOLD)


func _process_hold() -> void:
	_apply_text(_full_text.length())
	_apply_instability(0.0)

	if _elapsed >= hold_time:
		_enter_phase(Phase.GLITCH_OUT)


func _process_glitch_out() -> void:
	var progress: float = clampf(_elapsed / max(glitch_out_time, 0.01), 0.0, 1.0)

	# Characters scramble back into noise while the panel breaks up again.
	_apply_text(int(_full_text.length() * (1.0 - progress)))
	_apply_instability(progress)

	if _elapsed >= glitch_out_time:
		_finish()


## Shows the first `resolved` characters of the real name and fills the rest with
## random glyphs. Length stays constant, so the panel never changes width.
func _apply_text(resolved: int) -> void:
	var count: int = clampi(resolved, 0, _full_text.length())
	var out: String = _full_text.substr(0, count)

	for i in range(count, _full_text.length()):
		if _full_text[i] == " ":
			out += " "
		else:
			out += SCRAMBLE_CHARS[randi() % SCRAMBLE_CHARS.length()]

	level_name_label.text = out
	ghost_label.text = out


## `chaos`: 0 = perfectly still, 1 = maximum break-up.
func _apply_instability(chaos: float) -> void:
	var amount: float = clampf(chaos, 0.0, 1.0)

	center.position = Vector2(randf_range(-jitter_strength, jitter_strength) * amount, 0.0)
	ghost_label.position = Vector2(
		randf_range(-ghost_offset, ghost_offset) * amount,
		randf_range(-1.0, 1.0) * amount
	)


func _enter_phase(phase: int) -> void:
	_phase = phase
	_elapsed = 0.0
	_next_resolve_at = 0.0


func _finish() -> void:
	_phase = Phase.IDLE
	set_process(false)
	_apply_instability(0.0)

	# Hide only the title: the dim keeps fading, so this node stays visible until
	# that tween is done.
	center.visible = false

	var dim_tween := create_tween()
	dim_tween.tween_property(dim, "color:a", 0.0, 0.4)
	dim_tween.tween_callback(hide)
