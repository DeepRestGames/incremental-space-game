extends Node

# Scenes
var expedition_scene = preload("res://Scenes/Prototypes/Prototype_ExpeditionScene.tscn")
var main_scene = preload("res://Scenes/Prototypes/Prototype_MainScene.tscn")

# Player
var player: Player
var current_player_resource: int = 0

# DepositBox
var deposit_box_position: Vector2
var current_deposit_box_resource: int = 0

# Expedition
var expedition_started: bool = false


func _ready() -> void:
	# Level initialization
	# TODO Add logic to handle the menus navigation (e.g. in the start menu the node Player doesn't exist, but the GameManager singleton does
	player = get_tree().get_first_node_in_group("Player")
	deposit_box_position = get_tree().get_first_node_in_group("DepositBox").global_position
	
	print("Deposit box position: " + str(deposit_box_position))
	
	EventBus.connect("add_resource", add_resource)
	EventBus.connect("player_enter_deposit_box_area", add_resource_deposit_box)
	
	EventBus.connect("expedition_started", on_expedition_started)
	EventBus.connect("expedition_ended", on_expedition_ended)

func add_resource(resource_amount: int) -> void:
	current_player_resource += resource_amount
	
	print("Added resource")
	print("Total resources: " + str(current_player_resource))


func add_resource_deposit_box() -> void:
	current_deposit_box_resource += current_player_resource
	current_player_resource = 0
	
	print("Deposit box filled")
	print("Total deposit box resources: " + str(current_deposit_box_resource))


func on_expedition_started() -> void:
	get_tree().change_scene_to_packed(expedition_scene)
	expedition_started = true


func on_expedition_ended() -> void:
	get_tree().change_scene_to_packed(main_scene)
	expedition_started = false
