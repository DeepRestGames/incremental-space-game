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


func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(sprite, "offset", -hover_animation_movement_vector, hover_animation_cycle_duration)
	tween.chain().tween_property(sprite, "offset", hover_animation_movement_vector, hover_animation_cycle_duration)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		print("Player picked up " + pickup_name)
		
		EventBus.emit_signal("add_resource", pickup_amount)
		queue_free()
