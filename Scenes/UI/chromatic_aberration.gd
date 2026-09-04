extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	if material:
		print("Material: ", material.resource_path)
		print("Current intensity: ", material.get_shader_parameter("intensity"))
		print("modulate: ", modulate)
		print("self_modulate: ", self_modulate)
		print("visible: ", visible)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
