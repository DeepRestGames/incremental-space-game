class_name SpawnDistribution
extends Node

## What this planet spawns. One entry per rock type.
@export var entries: Array[SpawnEntry] = []


## scene -> weight as authored, before skills.
var spawn_distribution: Dictionary:
	get:
		var out := {}
		for e in entries:
			if e and e.scene:
				out[e.scene] = e.weight
		return out


## The weights actually used to spawn, skills applied. Generation and the level
## select both read this, so the percentages shown can't drift from what spawns.
func get_effective_weights() -> Dictionary:
	var out := {}
	for e in entries:
		if not e or not e.scene:
			continue
		var w := e.weight
		if e.weight_stat != "":
			if not BaseValuesDB.BASE_VALUES.has(e.weight_stat):
				push_warning("SpawnDistribution: unknown weight_stat '%s' on %s" % [
					e.weight_stat, e.scene.resource_path.get_file()])
			w = SkillModifiers.get_modified_stat(e.weight_stat, w)
		out[e.scene] = maxf(w, 0.0)
	return out
