class_name ConversionRecipe
extends Resource

@export var display_name: String              # "e.g. Smelt Ore, Make Chip"

## What it consumes. A dictionary so a recipe can take several ingredients.
@export var inputs: Dictionary[ResourceType, int] = {}

@export var output: ResourceType
@export var output_amount: int = 1

## Which station offers this, if we want to differentiate them
@export var station: StringName = &"shop"
