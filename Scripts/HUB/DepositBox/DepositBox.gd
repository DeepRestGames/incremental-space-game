class_name DepositBox
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		print("Player entered deposit box")
		
		EventBus.emit_signal("player_enter_deposit_box_area")
