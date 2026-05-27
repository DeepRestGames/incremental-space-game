extends Control


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func open() -> void:
	show()
	get_tree().paused = true
	GameManager.skill_tree_open = true


func close() -> void:
	hide()
	get_tree().paused = false
	GameManager.skill_tree_open = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
