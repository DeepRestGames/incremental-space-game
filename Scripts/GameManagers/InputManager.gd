extends Node


func _unhandled_input(_event: InputEvent) -> void:
	var movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	EventBus.emit_signal("player_movement", movement_direction)
