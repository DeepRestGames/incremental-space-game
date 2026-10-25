extends Area2D

## Material Processor Interactable
## Opens the ProcessorPanel UI when the player is nearby and presses interact.

var player_in_area: bool = false


## Shake while any processor row is converting.
@export var shake_amplitude: float = 2.0  ## max pixels away from rest
@export var shake_rate: float = 30.0      ## new random offsets per second

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _rest_position: Vector2 = _sprite.position
var _shake_timer: float = 0.0

func _ready() -> void:
	EventBus.action_trigger_interact.connect(check_interaction)
	# The panel pauses the game, but the machine keeps working, so keep shaking.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if not ProcessorManager.is_working():
		_sprite.position = _rest_position
		return
	_shake_timer -= delta
	if _shake_timer <= 0.0:
		_shake_timer = 1.0 / shake_rate
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		_sprite.position = _rest_position + offset * shake_amplitude

func check_interaction() -> void:
	if not player_in_area:
		return
	var ui = get_tree().current_scene.get_node_or_null("CanvasLayer/ProcessorPanel")
	if ui:
		if ui.visible:
			ui.close()
		else:
			ui.open()


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

		var ui = get_tree().current_scene.get_node_or_null("CanvasLayer/ProcessorPanel")
		if ui and ui.visible:
			ui.close()
