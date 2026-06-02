class_name DepositBox
extends Area2D

@onready var resource_number_label: Label = $ResourceNumberLabel


var player_in_area: bool = false


func _ready() -> void:
	resource_number_label.text = "0"
	EventBus.connect("update_HUD", update_HUD)
	EventBus.connect("action_trigger_interact", check_box_interaction)
	EventBus.emit_signal("on_deposit_box_ready", self)


func check_box_interaction() -> void:
	if player_in_area and GameManager.expedition_started:
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var popup = player.get_node_or_null("HUD/ConfirmationPopup")
			if popup:
				popup.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		if "inside_interactable_area" in body:
			body.inside_interactable_area = true
		EventBus.emit_signal("player_enter_deposit_box_area")
		if GameManager.expedition_started:
			EventBus.emit_signal("player_enter_expedition_return_area")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if "inside_interactable_area" in body:
			body.inside_interactable_area = false
		if GameManager.expedition_started:
			EventBus.emit_signal("player_exit_expedition_return_area")


func update_HUD() -> void:
	resource_number_label.text = str(GameManager.current_deposit_box_resource)
