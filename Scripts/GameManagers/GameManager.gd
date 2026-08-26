extends Node

# Scenes
var lobby_scene = preload("res://Scenes/Levels/Lobby.tscn")
## Which level the next expedition runs on. Only the id is stored: scene path and
## display name are always looked up from LevelDB, so they cannot drift apart.
var selected_level_id: String = LevelDB.DEFAULT_LEVEL_ID

# Player
var player: Player
var current_player_resource: int = 0


# Base stashed resources
var current_deposit_box_resource: int = 0

# Money (currency earned at the shop, spendable in the skill tree)
var current_money: int = 0

# Expedition
var expedition_started: bool = false
## Seconds left before oxygen starts draining. Counted down by _process while an
## expedition is running; the player can already move and mine during it.
var expedition_grace_remaining: float = 0.0
var previous_scene_path: String = ""
var skill_tree_open: bool = false:
	set(value):
		if skill_tree_open == value:
			return
		skill_tree_open = value
		EventBus.ui_state_changed.emit()

var level_select_open: bool = false:
	set(value):
		if level_select_open == value:
			return
		level_select_open = value
		EventBus.ui_state_changed.emit()

var confirmation_popup_open: bool = false:
	set(value):
		if confirmation_popup_open == value:
			return
		confirmation_popup_open = value
		EventBus.ui_state_changed.emit()
		
## True for the whole duration of a screen transition. Doubles as the
## re-entrancy guard for TransitionManager.change_scene().
var transitioning: bool = false:
	set(value):
		if transitioning == value:
			return
		transitioning = value
		EventBus.ui_state_changed.emit()

## Single owner of the engine pause flag. 
var game_paused: bool = false:
	set(value):
		if game_paused == value:
			return
		game_paused = value
		get_tree().paused = value
		EventBus.ui_state_changed.emit()


# Expedition Stats & Persistence
var open_level_select_on_lobby_load: bool = false
var expedition_time_spent: float = 0.0
var expedition_destroyed_nodes: int = 0
var expedition_resources_collected: int = 0
var _expedition_start_time_msec: int = 0
var expedition_success: bool = true
## Why the last expedition ended (e.g. "oxygen"). Empty when it ended normally.
var expedition_end_reason: String = ""

# Skill levels (skill_id -> current_points)
# Private on purpose: every write has to go through set_skill_points(),
# reset_skills() or load_skill_levels(), which all funnel into
# _on_skills_changed() so the stat cache can never go stale.
# Use get_skill_points() to read and get_skill_levels_snapshot() to save.
var _skill_levels: Dictionary = {
	"center_node": 1
}

# Base skills database (imported from SkillDB class). Read-only lookup table.
var skill_db: Dictionary = SkillDB.DATABASE


# Audio
var sfx_player: AudioStreamPlayer
var sfx_pickup = preload("res://Assets/Audio/SFX/BubblePop_audioStreamRandomizer.tres")
var sfx_inventory_full = preload("res://Assets/Audio/SFX/Denied.wav")


func _ready() -> void:
	
	# DEBUG_add_player_resources()
	
	# Level initialization
	# TODO Add logic to handle the menus navigation (e.g. in the start menu the node Player doesn't exist, but the GameManager singleton does
	
	EventBus.on_player_ready.connect(on_player_ready)

	EventBus.expedition_started.connect(on_expedition_started)

	# Build the stat cache before any scene node can read a stat.
	_on_skills_changed()
	
	#Initialize the audio player for system sounds (resource pickup sound)
	initialize_sfx_player()
	
	

func DEBUG_add_player_resources() -> void:
	add_resource(200)


func on_player_ready(player_reference: Player) -> void:
	player = player_reference


## Adds up to `amount` resources to the player's inventory, respecting the
## carrying capacity. Returns how many were actually accepted, so a pickup can
## keep the leftover instead of destroying it. Returns 0 when the player is full.
func add_resource(amount: int) -> int:
	var accepted: int = clampi(amount, 0, get_free_inventory_space())
	if accepted <= 0:
		#sfx_player.stream = sfx_inventory_full
		#sfx_player.play()
		return 0

	current_player_resource += accepted
	EventBus.update_HUD.emit()
	sfx_player.stream = sfx_pickup
	sfx_player.play()
	return accepted
	


## How many resources the player can carry, skill upgrades included.
func get_max_player_resource() -> int:
	return SkillModifiers.get_inventory_capacity()


func get_free_inventory_space() -> int:
	return maxi(get_max_player_resource() - current_player_resource, 0)


func is_inventory_full() -> bool:
	return get_free_inventory_space() <= 0


func _process(delta: float) -> void:
	if expedition_started and expedition_grace_remaining > 0.0:
		expedition_grace_remaining = max(expedition_grace_remaining - delta, 0.0)


## Records which level the next expedition will run on.
func select_level(level_id: String) -> void:
	if not LevelDB.has_level(level_id):
		push_error("GameManager: cannot select unknown level '%s'." % level_id)
		return
	selected_level_id = level_id


func get_selected_level_path() -> String:
	return LevelDB.get_scene_path(selected_level_id)


func get_selected_level_name() -> String:
	return LevelDB.get_level_name(selected_level_id)


## False during the opening grace period, so the player gets a moment to look
## around before the countdown starts.
func is_oxygen_draining() -> bool:
	return expedition_started and expedition_grace_remaining <= 0.0


func on_expedition_started() -> void:
	expedition_started = true
	expedition_grace_remaining = BaseValuesDB.EXPEDITION_GRACE_PERIOD
	_expedition_start_time_msec = Time.get_ticks_msec()
	expedition_destroyed_nodes = 0
	expedition_resources_collected = 0
	expedition_success = true
	expedition_end_reason = ""
	TransitionManager.change_scene(get_selected_level_path())


func end_expedition(success: bool = true, reason: String = "") -> void:
	if not expedition_started:
		return

	expedition_success = success
	expedition_end_reason = reason
	expedition_grace_remaining = 0.0
	
	# Calculate stats
	expedition_time_spent = (Time.get_ticks_msec() - _expedition_start_time_msec) / 1000.0
	
	# Add any carrying inventory resources to the total collected during expedition
	expedition_resources_collected += current_player_resource
	current_player_resource = 0

	# Finalize stashed resources based on success status
	if success:
		current_deposit_box_resource += expedition_resources_collected
	else:
		var stashed_amount = int(expedition_resources_collected * 0.2)
		current_deposit_box_resource += stashed_amount		
	get_tree().change_scene_to_file("res://Scenes/UI/expedition_ended.tscn")
	expedition_started = false


## Converts all stored deposit-box resources into money at the given rate.
## Returns how much money was earned (0 if there was nothing to convert).
func convert_resources_to_money(conversion_rate: float = 1.0) -> int:
	if current_deposit_box_resource <= 0:
		return 0

	var earned := int(current_deposit_box_resource * conversion_rate)
	current_deposit_box_resource = 0
	current_money += earned

	EventBus.update_HUD.emit()
	return earned


## Maximum number of levels the given skill can be upgraded to.
func get_skill_max_levels(skill_id: String) -> int:
	var skill_info = skill_db.get(skill_id, {})
	return len(skill_info.get("cost"))


## Money cost to buy one more level of the given skill.
func get_skill_cost(skill_id: String) -> int:
	var skill_info = skill_db.get(skill_id, {})
	var current_skill_level = get_skill_points(skill_id)
	if skill_info.get("cost") is Array:
		return int(skill_info.get("cost")[current_skill_level])
	else:
		return int(skill_info.get("cost", SkillDB.DEFAULT_UPGRADE_COST))

func can_afford(amount: int) -> bool:
	return current_money >= amount


func spend_money(amount: int) -> void:
	current_money = max(current_money - amount, 0)
	EventBus.update_HUD.emit()


func add_money(amount: int) -> void:
	current_money += amount
	EventBus.update_HUD.emit()


func get_oxygen_skill_multiplier() -> float:
	# Skill upgrades can modify this in the future (e.g. 0.8 for 20% slower depletion)
	return 1.0


func get_skill_points(skill_id: String) -> int:
	return _skill_levels.get(skill_id, 0)


func set_skill_points(skill_id: String, points: int) -> void:
	_skill_levels[skill_id] = points
	_on_skills_changed()


## Wipes every purchased skill, keeping only the always-on center node.
func reset_skills() -> void:
	_skill_levels = {
		"center_node": 1
	}
	_on_skills_changed()


## Replaces all skill levels at once, e.g. when loading a save file.
## Unknown skill ids are dropped and levels are clamped to the skill's maximum,
## so an outdated or hand-edited save cannot produce impossible stats.
func load_skill_levels(levels: Dictionary) -> void:
	_skill_levels = {
		"center_node": 1
	}
	for skill_id in levels:
		if not skill_db.has(skill_id):
			push_warning("Save file contains unknown skill '%s', ignored." % skill_id)
			continue
		var points: int = clampi(int(levels[skill_id]), 0, get_skill_max_levels(skill_id))
		_skill_levels[skill_id] = points

	_on_skills_changed()


## Copy of the current skill levels, for writing a save file.
func get_skill_levels_snapshot() -> Dictionary:
	return _skill_levels.duplicate()


## Single funnel for every change to _skill_levels. Rebuilds the stat cache,
## then tells everything that caches a derived value to refresh itself.
func _on_skills_changed() -> void:
	SkillModifiers.rebuild(_skill_levels, skill_db)

	# Refunding a capacity upgrade can push the cap below what is being carried.
	current_player_resource = mini(current_player_resource, get_max_player_resource())

	EventBus.stats_changed.emit()
	EventBus.update_HUD.emit()
	
## Another full-screen UI already owns the Escape key.
func is_modal_ui_open() -> bool:
	return skill_tree_open or level_select_open or confirmation_popup_open or transitioning
	
## The world is covered: world-space HUD elements should hide.
func is_world_obscured() -> bool:
	return is_modal_ui_open() or game_paused


func initialize_sfx_player() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = &"SFX"
	sfx_player.volume_db = -1.0
	add_child(sfx_player)
	
