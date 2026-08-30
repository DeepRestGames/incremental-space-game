extends GPUParticles2D


@onready var smaller_particles: GPUParticles2D = $smallerParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.emitting:
		smaller_particles.emitting = true
	
	else:
		smaller_particles.emitting = false
