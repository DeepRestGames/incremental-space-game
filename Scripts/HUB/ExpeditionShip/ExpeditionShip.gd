class_name ExpeditionShip
extends Area2D


@export var custom_texture: Texture2D

var player_in_area: bool = false


func _ready() -> void:
	EventBus.action_trigger_interact.connect(check_ship_interaction)
	if custom_texture:
		$ExpeditionShipBody/ExpeditionShipBodySprite.texture = custom_texture


func check_ship_interaction() -> void:
	if player_in_area:
		if GameManager.expedition_started and get_tree().current_scene.name != "Lobby":
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				var popup = player.get_node_or_null("HUD/ConfirmationPopup")
				if popup:
					popup.open()
				else:
					GameManager.end_expedition()
			else:
				GameManager.end_expedition()
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
		if "inside_interactable_area" in body:
			body.inside_interactable_area = true
		if GameManager.expedition_started:
			EventBus.player_enter_expedition_return_area.emit()
		else:
			EventBus.player_enter_expedition_ship_area.emit()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if "inside_interactable_area" in body:
			body.inside_interactable_area = false
		if GameManager.expedition_started:
			EventBus.player_exit_expedition_return_area.emit()
		else:
			EventBus.player_exit_expedition_ship_area.emit()
		
		# Close the Level Select UI if the player flies away
		var ui := get_tree().current_scene.get_node_or_null("CanvasLayer/LevelSelectUI")
		if ui and ui.visible:
			ui.close()
