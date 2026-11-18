extends GPUParticles2D

@onready var smaller_particles: GPUParticles2D = $smallerParticles


## Keeps the small dust in step with the main emitter, which Player toggles while walking.
func _process(_delta: float) -> void:
	smaller_particles.emitting = emitting
