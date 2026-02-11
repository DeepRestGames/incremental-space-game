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


func _ready() -> void:
	currentHP = totalHP
	
	EventBus.connect("action_trigger_interact", on_interacted)


func on_interacted() -> void:
	if not player_is_in_range:
		return
	
	EventBus.emit_signal("breakable_damaged")
	play_rock_particles()
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
