extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Return to the previous scene stored in GameManager
		if GameManager.previous_scene_path != "":
			get_tree().change_scene_to_file(GameManager.previous_scene_path)
		else:
			# Fallback to Main Menu if no previous path was recorded
			get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")
