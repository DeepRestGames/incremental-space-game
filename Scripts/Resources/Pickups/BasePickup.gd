class_name BasePickup
extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

@export_group("Animation")
@export var hover_animation_movement_vector: Vector2 = Vector2(0, 5)
@export var hover_animation_cycle_duration: float = .6

@export_group("Pickup Info")
@export var pickup_name: String
@export var pickup_amount: int = 1

@export_group("Player attraction")
var player_in_attraction_area: bool = false
@export var movement_speed: float = 200


func _ready() -> void:
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	#tween.tween_property(sprite, "offset", -hover_animation_movement_vector, hover_animation_cycle_duration)
	#tween.chain().tween_property(sprite, "offset", hover_animation_movement_vector, hover_animation_cycle_duration)
	#Initialize glowing animation
	animation_player.play()
	var random_time = randf_range(0.0, 0.7)
	var random_speed = randf_range(0.9, 1.1)
	animation_player.seek(random_time, true)
	animation_player.speed_scale = random_speed


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		print("Player picked up " + pickup_name)

		EventBus.emit_signal("add_resource", pickup_amount)
		queue_free()


func _physics_process(delta: float) -> void:
	if player_in_attraction_area:
		global_position = global_position.move_toward(GameManager.player.global_position, delta * movement_speed)


func _on_move_to_player_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attraction_area = true


func _on_move_to_player_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attraction_area = false


func randomize_spawn_direction() -> void:
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var spawn_linear_velocity = randi_range(120, 200)
	var spawn_angular_velocity = randf_range(2, 5)
	var spawn_duration = randf_range(.5, 1)
	
	var tween_y = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween_y.tween_property(self, "position:y", position.y + (direction.y * spawn_linear_velocity), spawn_duration)
	
	var tween_x = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "position:x", position.x + (direction.x * spawn_linear_velocity), spawn_duration)
	
	var tween_rotation = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_rotation.tween_property(self, "rotation", rotation + spawn_angular_velocity, spawn_duration)
