class_name LevelModifiers
extends Node

## Level-specific modifiers and roleplay conditions.

@export var drain_rate_multiplier: float = 1.0
@export var conditions: Array[String] = []

func get_oxygen_drain_multiplier() -> float:
	return drain_rate_multiplier

func get_conditions() -> Array[String]:
	return conditions
