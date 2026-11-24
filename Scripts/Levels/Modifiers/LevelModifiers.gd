class_name LevelModifiers
extends Node

const PATH := ^"Objects/Modifiers"
## Level-specific modifiers and roleplay conditions.

@export var drain_rate_multiplier: float = 1.0
@export var conditions: Array[LevelCondition] = []

#region lighting
## Ambient light of this level. White = fully lit (surface); darker = deeper layers.
@export var ambient_color: Color = Color.WHITE


func _ready() -> void:
	if not is_dark():
		return
	# Tints every CanvasItem on the main canvas: background, rocks, player, ship.
	# The HUD lives on its own CanvasLayer, so it stays bright.
	var darkness := CanvasModulate.new()
	darkness.color = ambient_color
	add_child(darkness)


func is_dark() -> bool:
	return ambient_color != Color.WHITE
#endregion

func get_oxygen_drain_multiplier() -> float:
	return drain_rate_multiplier

func get_conditions() -> Array[LevelCondition]:
	return conditions

## Finds the modifiers of `level` (a scene root). Null if it has none, e.g. the Lobby.
static func of(level: Node) -> LevelModifiers:
	if level == null:
		return null
	return level.get_node_or_null(PATH) as LevelModifiers
	
