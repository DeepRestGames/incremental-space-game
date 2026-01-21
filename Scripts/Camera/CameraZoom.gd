extends Node2D


@onready var camera: Camera2D = $".."

var default_walking_zoom = Vector2.ONE

var current_zoom: Vector2
var target_zoom: Vector2

var max_zoom = Vector2(.6, .6)
var min_zoom = Vector2(.2, .2)

var update_time = 1.0


func _process(delta: float) -> void:
	camera.zoom = lerp(camera.zoom, target_zoom, delta)


func update_camera_zoom_from_movement_speed(movement_speed: float) -> void:
	target_zoom = max_zoom - (min_zoom * movement_speed)
	
	#var zoom_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#zoom_tween.tween_property(camera, "zoom", target_zoom, update_time)


func update_camera_zoom(target_zoom: Vector2, update_time: float) -> void:
	var zoom_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(camera, "zoom", target_zoom, update_time)


func update_camera_zoom_walking() -> void:
	var zoom_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(camera, "zoom", default_walking_zoom, update_time)


func reset_camera_zoom(update_time: float) -> void:
	pass
