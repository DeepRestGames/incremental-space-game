extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		print("Player entered capture area")
		
		EventBus.emit_signal("player_enter_capture_area")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		print("Player exited capture area")
		
		EventBus.emit_signal("player_exit_capture_area")
