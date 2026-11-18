class_name DepthTracker
extends Node

const DESCENT_HOLE := preload("res://Scenes/Environment/DescentHole.tscn")

## Counts the damage dealt on this layer. Once it passes hp_to_open, the next
## destroyed rock with can_open_hole becomes the way down.
## Lives in the level scene, so every visit to a layer starts from zero.

## Damage to deal on this layer before a hole can open. Set per planet/layer.
@export var hp_to_open: int = 300

var damage_dealt: int = 0
var hole_opened: bool = false


func _ready() -> void:
	EventBus.breakable_damaged.connect(_on_breakable_damaged)
	EventBus.breakable_destroyed.connect(_on_breakable_destroyed)


func _on_breakable_damaged(damage_value: int, _is_crit: bool) -> void:
	damage_dealt += damage_value  # overkill counts too, by design


func _on_breakable_destroyed(rock: Breakable) -> void:
	if hole_opened or not rock.can_open_hole:
		return
	if damage_dealt < hp_to_open or not GameManager.can_descend():
		return
	hole_opened = true
	
	var hole := DESCENT_HOLE.instantiate() as DescentHole
	hole.position = rock.position
	# Deferred: this runs inside the rock's death, possibly mid physics step;
	# adding an Area2D right now can trigger "can't change state while flushing queries".
	rock.get_parent().add_child.call_deferred(hole)
