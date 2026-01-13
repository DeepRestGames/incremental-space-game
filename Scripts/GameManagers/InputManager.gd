extends Node


var prevent_inputs = false
var using_mouse = false

var looking_direction: Vector2

# Used to calculate looking direction when using mouse
var mouse_position_offset: Vector2


func _ready() -> void:
	#EventBus.connect("set_prevent_inputs", set_prevent_inputs)
	
	get_tree().root.size_changed.connect(update_viewport_size)
	update_viewport_size()


func update_viewport_size() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	mouse_position_offset = viewport_size / 2


func set_prevent_inputs(value: bool) -> void:
	prevent_inputs = value


func _unhandled_input(event: InputEvent) -> void:
	# Check if player is using mouse or pad
	if event is InputEventMouse:
		using_mouse = true
	else:
		using_mouse = false
	
	if prevent_inputs:
		return

	# Handle looking direction
	#if using_mouse:
		#var mouse_position = get_viewport().get_mouse_position()
		#looking_direction = (mouse_position - mouse_position_offset).normalized()
		#EventBus.emit_signal("looking_direction_changed", looking_direction)
	#elif event.is_action_pressed("look_left") or event.is_action_pressed("look_right") or event.is_action_pressed("look_up") or event.is_action_pressed("look_down"):
		#var temp_looking_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		## Discard all "ghost" inputs
		#if not temp_looking_direction.is_normalized():
			#return
		#looking_direction = temp_looking_direction
		#EventBus.emit_signal("looking_direction_changed", looking_direction)
	
	# Always check for player movement
	var movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	EventBus.emit_signal("player_movement", movement_direction)
