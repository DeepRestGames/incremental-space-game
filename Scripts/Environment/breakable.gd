extends StaticBody2D


@export var totalHP: int = 3
var currentHP: int

@onready var control: Control = $Control
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var player_is_in_range: bool = false

@onready var hit: AudioStreamPlayer = $Audio/Hit
@onready var destroy: AudioStreamPlayer = $Audio/Destroy

@onready var rock_particles_parent: Node2D = $RockParticlesParent
@onready var rock_particles = preload("res://Scenes/Particles/rock_particles.tscn")
var last_rock_particles_node: GPUParticles2D

@onready var pickup_spawner_scene = preload("uid://cgoo4dv0oy4c5")
var pickup_spawner: Node2D = pickup_spawner_scene
@export var spawn_pickup_chance = 0.5
@export var drop_amount: int = 5


func _ready() -> void:
	currentHP = totalHP
	
	EventBus.connect("action_trigger_interact", on_interacted)


func on_interacted() -> void:
	if not player_is_in_range:
		return
	
	EventBus.emit_signal("breakable_damaged")
	play_rock_particles()
	
	spawn_chips()
	
	currentHP -= 1
	last_rock_particles_node
	if currentHP <= 0:
		destroy.play()
		defer_destroy_object()
	else:
		hit.play()


func play_rock_particles() -> void:
	last_rock_particles_node = rock_particles.instantiate() as GPUParticles2D
	rock_particles_parent.add_child(last_rock_particles_node)
	last_rock_particles_node.restart()


func defer_destroy_object() -> void:
	collision_shape_2d.call_deferred("queue_free")
	control.hide()
	
	drop_loot()
		
	await last_rock_particles_node.finished
	
	call_deferred("queue_free")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		control.show()
		player_is_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		control.hide()
		player_is_in_range = false
		

func spawn_chips():
	#occasionally drop chips while mining
	var pickup_chance_roll = randf_range(0.0, 1.0)
	if pickup_chance_roll <= spawn_pickup_chance:
		pickup_spawner = pickup_spawner_scene.instantiate() as Node2D
		get_parent().add_child(pickup_spawner)
		pickup_spawner.global_position = global_position
		pickup_spawner.initialize()

func drop_loot():
	#drop chips when destroyed
	for i in drop_amount:
		pickup_spawner = pickup_spawner_scene.instantiate() as Node2D
		get_parent().add_child(pickup_spawner)
		var offset = Vector2(randf_range(-20,20), randf_range(-20,20))
		pickup_spawner.global_position = global_position + offset
		pickup_spawner.initialize()
