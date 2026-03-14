class_name DepositBox
extends Area2D

@onready var resource_number_label: Label = $ResourceNumberLabel


func _ready() -> void:
	resource_number_label.text = "0"
	EventBus.connect("update_HUD", update_HUD)
	
	EventBus.emit_signal("on_deposit_box_ready", self)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.emit_signal("player_enter_deposit_box_area")


func update_HUD() -> void:
	resource_number_label.text = str(GameManager.current_deposit_box_resource)
