extends Node2D
class_name ScreenShake


@onready var player_camera: Camera2D = $".."

#@export var random_shake_strenght: float = 20.0
@export var shake_decay_rate: float = 5.0

var rand
var shake_strength: float = 0.0


func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	set_process(false)


func _process(delta):
	shake_strength = move_toward(shake_strength, 0.0, shake_decay_rate * delta)
	if shake_strength == 0.0:
		player_camera.offset = Vector2.ZERO
		set_process(false)
		return
	player_camera.offset = get_random_offset()
		

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)


func screen_shake(magnitude := 20.0, decay_rate := 5.0):
	shake_strength = maxf(shake_strength, magnitude)
	shake_decay_rate = decay_rate
	set_process(true)
