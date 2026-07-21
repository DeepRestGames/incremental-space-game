class_name RockParticle
extends Node2D

func randomize_spawn_direction() -> void:
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var spawn_linear_velocity = randi_range(120, 200)
	var spawn_angular_velocity = randf_range(2, 5)
	var spawn_duration = randf_range(.5, 1)
	var lifetime = randf_range(9, 13)
	
	var tween_y = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween_y.tween_property(self, "position:y", position.y + (direction.y * spawn_linear_velocity), spawn_duration)
	
	var tween_x = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "position:x", position.x + (direction.x * spawn_linear_velocity), spawn_duration)
	
	var tween_rotation = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_rotation.tween_property(self, "rotation", rotation + spawn_angular_velocity, spawn_duration)
	
	var tween_fade_out = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_fade_out.tween_property(self, "modulate", Color(Color.WHITE, 0), lifetime)
	
	await tween_fade_out.finished
	queue_free()
