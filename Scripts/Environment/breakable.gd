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

@onready var sprite_2d: Sprite2D = $CollisionShape2D/Sprite2D
@export var rock_sprites: Array[Texture2D]

@onready var resource_scene: PackedScene = preload("res://Scenes/Resources/BasePickup.tscn")
@export var min_resource_number: int = 4
@export var max_resource_number: int = 10
var current_resource_number: int
@export var resource_spawn_chance_on_damaged: float = 0.9


func _ready() -> void:
	currentHP = totalHP
	current_resource_number = randi_range(min_resource_number, max_resource_number)
	
	sprite_2d.texture = rock_sprites.pick_random()
	
	EventBus.connect("action_trigger_interact", on_interacted)


func on_interacted() -> void:
	if not player_is_in_range:
		return
	
	EventBus.emit_signal("breakable_damaged")
	play_rock_particles()
	
	if randf_range(0, 1) < resource_spawn_chance_on_damaged:
		spawn_resource_drops(1)
	
	currentHP -= 1
	
	if currentHP <= 0:
		destroy.play()
		spawn_resource_drops(current_resource_number)
		defer_destroy_object()
	else:
		hit.play()


func spawn_resource_drops(resource_number: int) -> void:
	for i in resource_number:
		var resource_drop_node = resource_scene.instantiate() as BasePickup
		var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		resource_drop_node.global_position = self.global_position + random_offset
		get_tree().root.add_child(resource_drop_node)
		resource_drop_node.randomize_spawn_direction()
	
	current_resource_number -= resource_number


func play_rock_particles() -> void:
	last_rock_particles_node = rock_particles.instantiate() as GPUParticles2D
	rock_particles_parent.add_child(last_rock_particles_node)
	last_rock_particles_node.restart()


func defer_destroy_object() -> void:
	collision_shape_2d.call_deferred("queue_free")
	control.hide()
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
		
