extends Control


func _on_continue_button_pressed() -> void:
	# Placeholder
	pass


func _on_new_game_button_pressed() -> void:
	# Start a new game
	GameManager.expedition_started = false
	GameManager.skill_tree_open = false
	GameManager.level_select_open = false
	get_tree().change_scene_to_file("res://Scenes/Levels/Lobby.tscn")
	# TODO: make a transition with:
	# TransitionManager.change_scene(get_selected_level_path())


func _on_quit_button_pressed() -> void:
	# Quit
	get_tree().quit()
