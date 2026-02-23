extends Node2D

#scene of pickup to be spawned
@export var spawned_pickup_scene: PackedScene
var spawned_pickup: Node2D

#spawn animation parameters
@export var acceleration_min = 1.0
@export var acceleration_max = 2.0
@export var rotation_acceleration_min = -100
@export var rotation_acceleration_max = 100
@export var animation_duration_min = 0.2
@export var animation_duration_max = 0.5
var animation_duration: float
var elapsed_time: float = 0.0


func initialize() -> void:
	if spawned_pickup_scene == null:
		push_error("No pickup scene assigned.")
		return
	
	spawned_pickup = spawned_pickup_scene.instantiate() as Node2D
	get_parent().add_child(spawned_pickup)
	spawned_pickup.global_position = global_position
	
	var starting_acceleration = randf_range(acceleration_min, acceleration_max)
	var starting_direction: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var starting_rotation_acceleration = randf_range(rotation_acceleration_min, rotation_acceleration_max)
	var animation_duration = randf_range(animation_duration_min, animation_duration_max)

	# Assign starting values (must exist in pickup script)
	spawned_pickup.acceleration = starting_acceleration
	spawned_pickup.direction = starting_direction
	spawned_pickup.rotation_acceleration = starting_rotation_acceleration
	spawned_pickup.damping_time = animation_duration
	
	queue_free()
