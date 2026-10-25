class_name ConversionRecipe
extends Resource

@export var display_name: String              # "e.g. Smelt Ore, Make Chip"

## What it consumes. A dictionary so a recipe can take several ingredients.
@export var inputs: Dictionary[ResourceType, int] = {}

@export var output: ResourceType
@export var output_amount: int = 1

## Which station offers this, if we want to differentiate them
@export var station: StringName = &"shop"

## Base seconds one cycle takes before processor_speed upgrades.
@export var duration: float = 2.0

## The material this recipe consumes (null if inputs is empty).
func input_type() -> ResourceType:
	for t in inputs:
		return t
	return null


## How many units of input_type() one cycle consumes.
func input_amount() -> int:
	for t in inputs:
		return inputs[t]
	return 0
