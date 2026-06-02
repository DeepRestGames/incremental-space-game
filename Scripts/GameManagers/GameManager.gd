extends Node

# Scenes
var lobby_scene = preload("res://Scenes/Levels/Lobby.tscn")
var selected_level_path: String = "res://Scenes/Levels/Planets/Moon1234.tscn"

# Player
var player: Player
var current_player_resource: int = 0

# Base stashed resources
var current_deposit_box_resource: int = 0

# Expedition
var expedition_started: bool = false
var previous_scene_path: String = ""
var skill_tree_open: bool = false
var level_select_open: bool = false

# Expedition Stats & Persistence
var open_level_select_on_lobby_load: bool = false
var expedition_time_spent: float = 0.0
var expedition_destroyed_nodes: int = 0
var expedition_resources_collected: int = 0
var _expedition_start_time_msec: int = 0
var expedition_success: bool = true

# Skill levels (skill_id -> current_points)
var skill_levels: Dictionary = {
	"center_node": 1
}

# Base skills database (imported from SkillDB class)
var skill_db: Dictionary = SkillDB.DATABASE


func _ready() -> void:
	
	# DEBUG_add_player_resources()
	
	# Level initialization
	# TODO Add logic to handle the menus navigation (e.g. in the start menu the node Player doesn't exist, but the GameManager singleton does
	
	EventBus.connect("on_player_ready", on_player_ready)
	EventBus.connect("add_resource", add_resource)
	
	EventBus.connect("expedition_started", on_expedition_started)
	EventBus.connect("expedition_ended", on_expedition_ended)


func DEBUG_add_player_resources() -> void:
	current_player_resource = 200


func on_player_ready(player_reference: Player) -> void:
	player = player_reference
func add_resource(resource_amount: int) -> void:
	current_player_resource += resource_amount
	
	print("Added resource")
	print("Total resources: " + str(current_player_resource))
	
	EventBus.emit_signal("update_HUD")
func on_expedition_started() -> void:
	get_tree().change_scene_to_file(selected_level_path)
	expedition_started = true
	_expedition_start_time_msec = Time.get_ticks_msec()
	expedition_destroyed_nodes = 0
	expedition_resources_collected = 0
	expedition_success = true


func on_expedition_ended() -> void:
	get_tree().change_scene_to_packed(lobby_scene)
	expedition_started = false


func end_expedition(success: bool = true) -> void:
	if not expedition_started:
		return
		
	expedition_success = success
	
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
		
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/expedition_ended.tscn")
	expedition_started = false


func get_oxygen_skill_multiplier() -> float:
	# Skill upgrades can modify this in the future (e.g. 0.8 for 20% slower depletion)
	return 1.0


func get_skill_points(skill_id: String) -> int:
	return skill_levels.get(skill_id, 0)


func set_skill_points(skill_id: String, points: int) -> void:
	skill_levels[skill_id] = points
	EventBus.emit_signal("update_HUD")
	if player and player.has_method("update_stats"):
		player.update_stats()


func get_stat_modifier(stat_name: String) -> float:
	var total = 0.0
	for skill_id in skill_levels:
		var points = skill_levels[skill_id]
		var skill_info = skill_db.get(skill_id, {})
		var effects = skill_info.get("effects", {})
		if stat_name in effects:
			total += effects[stat_name] * points
	return total


func get_modified_stat(stat_name: String, base_value: float) -> float:
	return base_value + get_stat_modifier(stat_name)


	
