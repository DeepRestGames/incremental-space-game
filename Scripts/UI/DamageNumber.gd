class_name DamageNumber
extends Node2D

@export var rise_distance: float = 48.0
@export var lifetime: float = 0.8
@export var normal_color: Color = Color(1, 1, 1) # TODO: make a unique thing to pick somewhere
@export var crit_color: Color = Color(1, 0.78, 0.2) # TODO: make a unique thing to pick somewhere
@export var crit_scale: float = 1.5
## Sideways spread so simultaneous hits do not stack into an unreadable blob.
@export var drift: float = 16.0

@onready var label: Label = $Label


func show_damage(amount: int, is_crit: bool) -> void:
	label.text = str(amount)
	label.modulate = crit_color if is_crit else normal_color
	scale = Vector2.ONE * (crit_scale if is_crit else 1.0)

	var target := position + Vector2(randf_range(-drift, drift), -rise_distance)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", target, lifetime) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, "modulate:a", 0.0, lifetime).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
