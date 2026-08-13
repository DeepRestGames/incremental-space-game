class_name ConfirmationPopup
extends Control

## A confirmation popup overlay that pauses the game and prompts the player.

func _ready() -> void:
	hide()
	# Ensure the popup can process inputs while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func open() -> void:
	GameManager.confirmation_popup_open = true
	GameManager.game_paused = true
	show()


func close() -> void:
	GameManager.confirmation_popup_open = false
	GameManager.game_paused = false
	hide()


func _on_yes_button_pressed() -> void:
	close()
	GameManager.end_expedition()


func _on_no_button_pressed() -> void:
	close()
