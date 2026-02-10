extends Node2D


@onready var screen_shake: ScreenShake = $"../PlayerCamera/ScreenShake"


var breakable_locked = false


func _ready() -> void:
	EventBus.connect("breakable_damaged", on_breakable_damaged)


func on_breakable_damaged() -> void:
	screen_shake.screen_shake(10, 8)
