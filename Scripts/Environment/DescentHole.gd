class_name DescentHole
extends Area2D

## The way down to the next layer. Spawned by DepthTracker where the chosen rock died.

var _player_in_area: bool = false

@onready var _sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	EventBus.action_trigger_interact.connect(_on_interact)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Open up: grow from nothing, like the ground caving in.
	_sprite.scale = Vector2.ZERO
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) \
			.tween_property(_sprite, "scale", Vector2.ONE, 0.5)


func _on_interact() -> void:
	if _player_in_area:
		GameManager.descend()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_area = true
		body.inside_interactable_area = true  # stops drilling while standing here
		EventBus.player_enter_descent_area.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_area = false
		body.inside_interactable_area = false
		EventBus.player_exit_descent_area.emit()
