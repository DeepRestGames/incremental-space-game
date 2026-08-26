extends Control

func _ready() -> void:
	hide()
	# Allow the pause menu to run while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GameManager.is_modal_ui_open():
			return
		toggle_pause()


func toggle_pause() -> void:
	GameManager.game_paused = not GameManager.game_paused
	visible = GameManager.game_paused


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_back_to_menu_button_pressed() -> void:
	# Unpause the engine before loading the main menu
	GameManager.game_paused = false
	GameManager.expedition_started = false
	GameManager.skill_tree_open = false
	GameManager.level_select_open = false
	get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")
	# TODO: make a transition with:
	# TransitionManager.change_scene(get_selected_level_path())
