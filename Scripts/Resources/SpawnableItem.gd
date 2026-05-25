class_name SpawnableItem
extends Resource

## Name or identifier of spawnable item
@export var name: String = "Spawnable"

## The PackedScene representing this spawnable item (e.g., breakable_small.tscn).
@export var scene: PackedScene

## Relative weight for spawning probability. 
## E.g., if one item has weight 8 and another has 2,
## they will be spawned in an 80% to 20% ratio.
@export var weight: float = 1.0
