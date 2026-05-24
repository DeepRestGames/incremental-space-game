extends Control


func _on_continue_button_pressed() -> void:
	# Placeholder
	pass


func _on_new_game_button_pressed() -> void:
	# Start a new game
	get_tree().change_scene_to_file("res://Scenes/Prototypes/Prototype_MainScene.tscn")


func _on_skill_tree_test_button_pressed() -> void:
	# Test skill tree
	GameManager.previous_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://Scenes/UI/skill_tree.tscn")



func _on_quit_button_pressed() -> void:
	# Quit
	get_tree().quit()
