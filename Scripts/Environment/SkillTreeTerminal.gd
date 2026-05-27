extends Area2D

## Skill Tree Terminal Interactable
## Opens the Skill Tree Upgrade scene when the player is nearby and presses E.

var player_in_area: bool = false

@onready var prompt: Label = $PromptLabel

func _ready() -> void:
	prompt.hide()
	EventBus.connect("action_trigger_interact", check_interaction)


func check_interaction() -> void:
	if player_in_area:
		# Save current Lobby path as previous scene before transitioning
		GameManager.previous_scene_path = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file("res://Scenes/UI/skill_tree.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		prompt.hide()
