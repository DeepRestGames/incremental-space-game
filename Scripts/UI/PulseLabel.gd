@tool
extends Label

## Grows and shrinks forever

@export var pulse_scale: float = 1.08
@export var period: float = 1.2


func _ready() -> void:
	# Scale grows from the pivot, which defaults to the top-left corner.
	resized.connect(_center_pivot)
		# Keep it centred - also after a container resizes the label.
	_center_pivot()
	if Engine.is_editor_hint():
		return  # centred pivot in the editor too, but no pulsing while editing

	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * pulse_scale, period * 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, period * 0.5)


func _center_pivot() -> void:
	pivot_offset = size / 2
