class_name LevelDB

## Every playable planet, in the order the level select shows them.
## Same pattern as ResourceDB: one LevelData .tres per planet, listed here.

const BASTET := preload("res://GameResources/Levels/bastet.tres")
const YAM := preload("res://GameResources/Levels/yam.tres")

const ALL: Array[LevelData] = [BASTET, YAM]

## Level id used when nothing has been selected yet.
const DEFAULT_LEVEL_ID: StringName = &"bastet"

static var _by_id: Dictionary = {}


static func _index() -> Dictionary:
	if _by_id.is_empty():
		for l in ALL:
			_by_id[l.id] = l
	return _by_id


static func has_level(level_id: String) -> bool:
	return _index().has(StringName(level_id))


static func get_level(level_id: String) -> LevelData:
	var l = _index().get(StringName(level_id))
	if l == null:
		push_error("LevelDB: unknown level id '%s'." % level_id)
		return _index()[DEFAULT_LEVEL_ID]
	return l


## Level ids in display order.
static func get_ids() -> Array:
	return ALL.map(func(l): return l.id)


static func get_level_name(level_id: String) -> String:
	return get_level(level_id).display_name


static func get_scene_path(level_id: String) -> String:
	return get_level(level_id).scene_path


static func get_planet_texture(level_id: String) -> Texture2D:
	return get_level(level_id).planet_texture
