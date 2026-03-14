extends Node2D
class_name PlayerInput


@export var drill_cooldown: float = 1
var current_drill_cooldown: float = 0
var drill_action_pressed: bool = false

@onready var bomb_spawner: BombSpawner = $"../BombSpawner"


func _process(delta: float) -> void:
	if current_drill_cooldown > 0:
		current_drill_cooldown -= delta
	
	if drill_action_pressed and current_drill_cooldown <= 0:
		EventBus.emit_signal("action_trigger_interact")
		current_drill_cooldown = drill_cooldown


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		drill_action_pressed = true

	if event.is_action_released("interact"):
		drill_action_pressed = false
	
	if event.is_action_pressed("place_bomb"):
		bomb_spawner.spawn_bomb(global_position)
