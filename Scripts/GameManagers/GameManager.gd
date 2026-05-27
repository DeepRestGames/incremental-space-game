extends Node

# Scenes
var lobby_scene = preload("res://Scenes/Levels/Lobby.tscn")
var selected_level_path: String = "res://Scenes/Levels/Planets/Moon1234.tscn"

# Player
var player: Player
var current_player_resource: int = 0

# DepositBox
var deposit_box: DepositBox
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






func _ready() -> void:
	
	# DEBUG_add_player_resources()
	
	# Level initialization
	# TODO Add logic to handle the menus navigation (e.g. in the start menu the node Player doesn't exist, but the GameManager singleton does
	
	EventBus.connect("on_player_ready", on_player_ready)
	EventBus.connect("on_deposit_box_ready", on_deposit_box_ready)
	
	EventBus.connect("add_resource", add_resource)
	EventBus.connect("player_enter_deposit_box_area", add_resource_deposit_box)
	
	EventBus.connect("expedition_started", on_expedition_started)
	EventBus.connect("expedition_ended", on_expedition_ended)


func DEBUG_add_player_resources() -> void:
	current_player_resource = 200


func on_player_ready(player_reference: Player) -> void:
	player = player_reference


func on_deposit_box_ready(deposit_box_reference: DepositBox) -> void:
	deposit_box = deposit_box_reference


func add_resource(resource_amount: int) -> void:
	current_player_resource += resource_amount
	
	print("Added resource")
	print("Total resources: " + str(current_player_resource))
	
	EventBus.emit_signal("update_HUD")


func add_resource_deposit_box() -> void:
	if current_player_resource <= 0:
		return
	
	EventBus.emit_signal("start_resource_transfer_animation_to_deposit_box", current_player_resource)
	
	current_deposit_box_resource += current_player_resource
	if expedition_started:
		expedition_resources_collected += current_player_resource
	current_player_resource = 0
	
	EventBus.emit_signal("update_HUD")


func on_expedition_started() -> void:
	get_tree().change_scene_to_file(selected_level_path)
	expedition_started = true
	_expedition_start_time_msec = Time.get_ticks_msec()
	expedition_destroyed_nodes = 0
	expedition_resources_collected = 0


func on_expedition_ended() -> void:
	get_tree().change_scene_to_packed(lobby_scene)
	expedition_started = false


func end_expedition() -> void:
	if not expedition_started:
		return
		
	# Calculate stats
	expedition_time_spent = (Time.get_ticks_msec() - _expedition_start_time_msec) / 1000.0
	
	# Discard inventory resources (only deposited ones are saved)
	current_player_resource = 0
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/expedition_ended.tscn")
	expedition_started = false


func get_oxygen_skill_multiplier() -> float:
	# Skill upgrades can modify this in the future (e.g. 0.8 for 20% slower depletion)
	return 1.0


	
