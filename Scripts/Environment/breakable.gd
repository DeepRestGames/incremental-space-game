extends StaticBody2D


@export var totalHP: int = 3
var currentHP: int

@onready var control: Control = $Control
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var player_is_in_range: bool = false


func _ready() -> void:
	currentHP = totalHP
	
	EventBus.connect("action_trigger_interact", on_interacted)


func on_interacted() -> void:
	if not player_is_in_range:
		return
	
	currentHP -= 1
	if currentHP <= 0:
		call_deferred("queue_free")
	
	gpu_particles_2d.restart()
	EventBus.emit_signal("breakable_damaged")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		control.show()
		player_is_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		control.hide()
		player_is_in_range = false
