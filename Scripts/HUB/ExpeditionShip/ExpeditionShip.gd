class_name ExpeditionShip
extends Area2D


var player_in_area: bool = false


func _ready() -> void:
	EventBus.connect("action_trigger_interact", check_ship_interaction)


func check_ship_interaction() -> void:
	if player_in_area:
		if GameManager.expedition_started and get_tree().current_scene.name != "Lobby":
			EventBus.emit_signal("expedition_ended")
		else:
			# In the lobby, interacting with the ship opens the Level Select UI
			var ui := get_tree().current_scene.get_node_or_null("CanvasLayer/LevelSelectUI")
			if ui:
				if ui.visible:
					ui.close()
				else:
					ui.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		EventBus.emit_signal("player_enter_expedition_ship_area")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		EventBus.emit_signal("player_exit_expedition_ship_area")
		
		# Close the Level Select UI if the player flies away
		var ui := get_tree().current_scene.get_node_or_null("CanvasLayer/LevelSelectUI")
		if ui and ui.visible:
			ui.close()
