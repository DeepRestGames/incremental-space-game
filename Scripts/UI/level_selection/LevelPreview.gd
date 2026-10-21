class_name LevelPreview

## Everything the level select shows about a planet, read from the planet scene
## itself. Instancing a planet isn't free, so each one is read once and cached;
## call clear_cache() when something that changes the numbers happens (skills).

static var _cache: Dictionary = {}


static func clear_cache() -> void:
	_cache.clear()


## {rocks: [{texture, pct, drops: [{icon, text}]}],
##  conditions: [LevelCondition], oxygen_multiplier: float}
## Rocks are sorted most common first.
static func read(level: LevelData) -> Dictionary:
	if _cache.has(level.id):
		return _cache[level.id]
	var info := {"rocks": [], "conditions": [], "oxygen_multiplier": 1.0}
	if level.is_playable():
		# Instanced but never added to the tree: _ready() doesn't run, so the
		# planet generates nothing - we only read its configuration.
		var planet: Node = load(level.scene_path).instantiate()
		info["rocks"] = _read_rocks(planet)
		var mods := planet.get_node_or_null("Objects/Modifiers") as LevelModifiers
		if mods:
			info["conditions"] = mods.get_conditions()
			info["oxygen_multiplier"] = mods.get_oxygen_drain_multiplier()
		planet.free()
	_cache[level.id] = info
	return info


static func _read_rocks(planet: Node) -> Array:
	var rocks: Array = []
	var gen = planet.get_node_or_null("Objects/MapCoordinateGenerator")
	if gen == null:
		return rocks
	var weights: Dictionary = gen.get_effective_weights()
	var total := 0.0
	for scene in weights:
		total += weights[scene]
	if total > 0.0:
		for scene in weights:
			rocks.append(_read_rock(scene, weights[scene] / total * 100.0))
	rocks.sort_custom(func(a, b): return a["pct"] > b["pct"])
	return rocks
	
	
static func _read_rock(scene: PackedScene, pct: float) -> Dictionary:
	var rock: Node = scene.instantiate()
	var info := {
		"texture": rock.get_node("CanvasGroup/Sprite2D").texture,
		"pct": roundi(pct),
		"drops": [],
	}
	for entry in rock.drops:
		if entry and entry.scene:
			var pickup: Node = entry.scene.instantiate()
			if pickup.resource_type:
				info["drops"].append({"icon": pickup.resource_type.icon, "text": _range_text(entry)})
			pickup.free()
	rock.free()
	return info


## "2-3" guaranteed, "2-3+" if it can also drop while drilling, "?" if only then.
static func _range_text(e: DropEntry) -> String:
	if e.max_amount <= 0:
		return "?" if e.drops_while_drilling else ""
	var text := str(e.min_amount) if e.min_amount == e.max_amount else "%d-%d" % [e.min_amount, e.max_amount]
	return text + ("+" if e.drops_while_drilling else "")
