extends Area2D

## Shop / Merchant Interactable
## When the player is nearby and presses the interact key, converts all
## collected resources stored at the base into money to spend in the skill tree.

## How much money one unit of resource is worth. Tweak in the Inspector.
@export var conversion_rate: float = 1.0

var player_in_area: bool = false


func _ready() -> void:
	EventBus.connect("action_trigger_interact", check_interaction)


func check_interaction() -> void:
	if player_in_area:
		GameManager.convert_resources_to_money(conversion_rate)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		if "inside_interactable_area" in body:
			body.inside_interactable_area = true
		EventBus.emit_signal("player_enter_shop_area")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if "inside_interactable_area" in body:
			body.inside_interactable_area = false
		EventBus.emit_signal("player_exit_shop_area")
