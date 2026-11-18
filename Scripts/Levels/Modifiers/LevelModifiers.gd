class_name LevelModifiers
extends Node

const PATH := ^"Objects/Modifiers"
## Level-specific modifiers and roleplay conditions.

@export var drain_rate_multiplier: float = 1.0
@export var conditions: Array[LevelCondition] = []

func get_oxygen_drain_multiplier() -> float:
	return drain_rate_multiplier

func get_conditions() -> Array[LevelCondition]:
	return conditions

## Finds the modifiers of `level` (a scene root). Null if it has none, e.g. the Lobby.
static func of(level: Node) -> LevelModifiers:
	if level == null:
		return null
	return level.get_node_or_null(PATH) as LevelModifiers
	
