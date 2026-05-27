extends Control


func _ready() -> void:
	hide()
	# Allow the pause menu to run while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GameManager.level_select_open or GameManager.skill_tree_open:
			return
		toggle_pause()


func toggle_pause() -> void:
	var new_paused_state = !get_tree().paused
	get_tree().paused = new_paused_state
	visible = new_paused_state


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_back_to_menu_button_pressed() -> void:
	# Unpause the engine before loading the main menu
	get_tree().paused = false
	GameManager.expedition_started = false
	GameManager.skill_tree_open = false
	GameManager.level_select_open = false
	get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")
