class_name RockParticle
extends Node2D

@export var particle_sprites: Array[Texture2D]

@onready var sprite_2d: Sprite2D = $Sprite2D

func randomize_spawn_direction() -> void:
	sprite_2d.texture = particle_sprites.pick_random()
	
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var spawn_linear_velocity = randi_range(120, 300)
	var spawn_angular_velocity = randf_range(2, 5)
	var spawn_duration = randf_range(.5, 1)
	var lifetime = randf_range(2, 4)
	
	#sprite starting y position (= starting fake z)
	var starting_z = randf_range(-10, -50)
	var z_height = randf_range(50, 100)
	sprite_2d.position.y = starting_z


	var tween_y = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "position:y", position.y + (direction.y * spawn_linear_velocity), spawn_duration)
	
	#fake z movement
	var tween_z = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween_z.tween_property(sprite_2d, "position:y", starting_z - z_height, spawn_duration/4).set_trans(Tween.TRANS_CUBIC)
	tween_z.tween_property(sprite_2d, "position:y", 0, spawn_duration/4*3).set_trans(Tween.TRANS_BOUNCE)
	
	
	var tween_x = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "position:x", position.x + (direction.x * spawn_linear_velocity), spawn_duration)
	
	var tween_rotation = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_rotation.tween_property(sprite_2d, "rotation", rotation + spawn_angular_velocity, spawn_duration)
	
	var tween_fade_out = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	tween_fade_out.tween_property(self, "modulate", Color(Color.WHITE, 0), lifetime)
	
	await tween_fade_out.finished
	

	

	queue_free()
