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


#variables for when the pickup is being spawned
var acceleration: float = 0.0
var direction: Vector2 = Vector2.ZERO
var rotation_acceleration: float = 0.0
var damping_time: float = 0.0

var velocity: Vector2 = Vector2.ZERO
var rotation_velocity: float = 0.0

var elapsed_time: float = 0.0



func _ready() -> void:
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	#tween.tween_property(sprite, "offset", -hover_animation_movement_vector, hover_animation_cycle_duration)
	#tween.chain().tween_property(sprite, "offset", hover_animation_movement_vector, hover_animation_cycle_duration)
	sprite.rotation = randi_range(-180, 180)
	#Initialize glowing animation
	animation_player.play()
	var random_time = randf_range(0.0, 0.7)
	var random_speed = randf_range(0.9, 1.1)
	animation_player.seek(random_time, true)
	animation_player.speed_scale = random_speed



func _process(delta: float) -> void:
	if damping_time <= 0.0:
		return

	elapsed_time += delta
	
	var t : float = clamp(elapsed_time / damping_time, 0.0, 1.0)
	var damping : float = 1.0 - t
	
	# Apply movement
	velocity = direction * acceleration * damping
	rotation_velocity = rotation_acceleration * damping
	
	position += velocity * delta
	rotation += rotation_velocity * delta
	
	# Stop completely when done
	if t >= 1.0:
		acceleration = 0.0
		rotation_acceleration = 0.0
		damping_time = 0.0



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		print("Player picked up " + pickup_name)

		EventBus.emit_signal("add_resource", pickup_amount)
		queue_free()
