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
		var ui = get_tree().current_scene.get_node_or_null("CanvasLayer/SkillTree")
		if ui:
			if ui.visible:
				ui.close()
			else:
				ui.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		if "inside_interactable_area" in body:
			body.inside_interactable_area = true
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if "inside_interactable_area" in body:
			body.inside_interactable_area = false
		prompt.hide()
		
		# Close the Skill Tree if the player flies away
		var ui = get_tree().current_scene.get_node_or_null("CanvasLayer/SkillTree")
		if ui and ui.visible:
			ui.close()
