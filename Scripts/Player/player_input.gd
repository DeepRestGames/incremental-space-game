extends Node2D
class_name PlayerInput


var drill_cooldown: float = BaseValuesDB.DRILL_ATTACK_SPEED
var current_drill_cooldown: float = 0

@onready var bomb_spawner: BombSpawner = $"../BombSpawner"

func _ready() -> void:
	EventBus.connect("stats_changed", update_stats)
	update_stats()

func _process(delta: float) -> void:
	
	if current_drill_cooldown > 0:
		current_drill_cooldown -= delta
	
	if Input.is_action_pressed("interact") and current_drill_cooldown <= 0:
		EventBus.emit_signal("action_trigger_interact")
		current_drill_cooldown = drill_cooldown


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_bomb"):
		var player = get_parent()
		if player and player.has_method("use_bomb"):
			if player.use_bomb():
				bomb_spawner.spawn_bomb(global_position)

func update_stats() -> void:
	drill_cooldown = 0.5**(SkillModifiers.get_drill_attack_speed()-1)
