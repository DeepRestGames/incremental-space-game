extends Node2D
class_name PlayerInput


var drill_cooldown: float = BaseValuesDB.DRILL_ATTACK_SPEED
var current_drill_cooldown: float = 0
@export var mining_reticle_base_rotation_speed: float = 2

#Graphics
var mining_reticle_rotation: float = 2
@onready var mining_reticle_material = $"../MiningReticle/DiggingCircle".material
@onready var reticle_animation_player = $"../MiningReticle/AnimationPlayer"

#SFX
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer_hit"


@onready var bomb_spawner: BombSpawner = $"../BombSpawner"

func _ready() -> void:
	EventBus.stats_changed.connect(update_stats)
	update_stats()

func _process(delta: float) -> void:
	
	if GameManager.expedition_started:
		if current_drill_cooldown > 0:
			current_drill_cooldown -= delta
	
		if Input.is_action_pressed("interact") and current_drill_cooldown <= 0:
			EventBus.action_trigger_interact.emit()
			reticle_animation_player.play("tick")
			audio_stream_player.play()
			current_drill_cooldown = drill_cooldown
	
	else:
		if Input.is_action_pressed("interact"):
			EventBus.action_trigger_interact.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_bomb"):
		var player = get_parent()
		if player and player.has_method("use_bomb"):
			if player.use_bomb():
				bomb_spawner.spawn_bomb(global_position)

func update_stats() -> void:
	drill_cooldown = 0.5**(SkillModifiers.get_drill_attack_speed()-1)
	var mining_reticle_new_rotation_speed: float
	mining_reticle_new_rotation_speed = mining_reticle_base_rotation_speed*SkillModifiers.get_drill_attack_speed()
	mining_reticle_material.set_shader_parameter("circle_rotation_speed", mining_reticle_new_rotation_speed)
	mining_reticle_material.set_shader_parameter("cross_rotation_speed", mining_reticle_new_rotation_speed)
	#print (drill_cooldown)
