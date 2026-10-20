extends Area2D

## Shop / Merchant Interactable
## When the player is nearby and presses the interact key, converts all
## collected resources stored at the base into money to spend in the skill tree.

## How much money one unit of resource is worth. Tweak in the Inspector.
@export var conversion_rate: float = 1.0
var player_in_area: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	EventBus.action_trigger_interact.connect(check_interaction)

## Shop / Merchant Interactable
## When the player is nearby and presses interact, runs every shop recipe as
## many times as the stored resources allow.
## TODO: replace with a selection UI once recipes are more than one.

func check_interaction() -> void:
	if not player_in_area:
		return
	for recipe in RecipeDB.recipes_for(&"processor"):
		GameManager.craft(recipe, GameManager.max_crafts(recipe))
		shake()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		if "inside_interactable_area" in body:
			body.inside_interactable_area = true
		EventBus.player_enter_shop_area.emit()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		if "inside_interactable_area" in body:
			body.inside_interactable_area = false
		EventBus.player_exit_shop_area.emit()

func shake() -> void:
	var tween_x = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_x.set_loops(5)
	tween_x.tween_property(sprite_2d, "position:x", 15, 0.01)
	tween_x.tween_property(sprite_2d, "position:x", 0, 0.01)
	tween_x.tween_property(sprite_2d, "position:x", -15, 0.01)
	tween_x.tween_property(sprite_2d, "position:x", 0, 0.01)

	
	#var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	#tween.set_loops(5)
	#tween.tween_property(sprite_2d, "skew", 5, 0.01)
	#tween.tween_property(sprite_2d, "skew", 0, 0.01)
	#tween.tween_property(sprite_2d, "skew", -5, 0.01)
	#tween.tween_property(sprite_2d, "skew", 0, 0.01)
