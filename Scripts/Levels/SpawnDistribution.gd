class_name SpawnDistribution
extends Node

## Holds the spawn distribution configuration (PackedScene -> float weight)
@export var spawn_distribution: Dictionary[PackedScene, float] = {}

## Optional: which skill stat scales each entry's weight on THIS planet.
## Entries not listed are never touched by skills. Several entries can share
## one stat, so a single upgrade can thin out every common rock at once.
@export var weight_stats: Dictionary[PackedScene, StringName] = {}


## The weights actually used to spawn, skills applied. Generation and the level
## select both read this, so the percentages shown can't drift from what spawns.
func get_effective_weights() -> Dictionary[PackedScene, float]:
	var out: Dictionary[PackedScene, float] = {}
	for scene in spawn_distribution:
		var w: float = spawn_distribution[scene]
		var stat: StringName = weight_stats.get(scene, &"")
		if stat != &"":
			w = SkillModifiers.get_modified_stat(stat, w)
		out[scene] = maxf(w, 0.0)
	return out
