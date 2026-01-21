extends Node2D


@onready var camera: Camera2D = $".."

@export var random_shake_strenght: float = 20.0
@export var shake_decay_rate: float = 5.0

var rand
var shake_strenght: float = 0.0


func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	
	EventBus.connect("screen_shake", screen_shake)


func _process(delta):
	shake_strenght = lerp(shake_strenght, 0.0, shake_decay_rate * delta)
	camera.offset = get_random_offset()


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strenght, shake_strenght),
		rand.randf_range(-shake_strenght, shake_strenght)
	)


func screen_shake(magnitude:= 20.0, decay_rate:= 5.0):
	shake_strenght = magnitude
	shake_decay_rate = decay_rate
