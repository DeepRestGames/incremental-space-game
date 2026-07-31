class_name LevelDB

## Read-only database of every playable level, keyed by level id.
##
## Same role as SkillDB: the single place where level data lives. Nothing writes
## to it at runtime (it is a const, so Godot enforces that) - LevelSelectUI keeps
## the values it computes per run in its own dictionary instead.

const PLANET_PATH: String = "res://Scenes/Levels/Planets/"

const DATABASE: Dictionary = {
	"moon_1234": {
		"name": "MOON 1234",
		"scene_path": PLANET_PATH + "Moon1234.tscn",
		"planet_color": Color(0.65, 0.68, 0.72)
	},
	"nebula_alpha": {
		"name": "NEBULA ALPHA",
		"scene_path": PLANET_PATH + "NebulaAlpha2345.tscn",
		"planet_color": Color(0.9, 0.25, 0.6)
	}
}

## Level id used when nothing has been selected yet.
const DEFAULT_LEVEL_ID: String = "moon_1234"


static func has_level(level_id: String) -> bool:
	return DATABASE.has(level_id)


## Level ids in declaration order - the order the level select carousel uses.
static func get_ids() -> Array:
	return DATABASE.keys()


static func get_level(level_id: String) -> Dictionary:
	if not DATABASE.has(level_id):
		push_error("LevelDB: unknown level id '%s'." % level_id)
		return DATABASE[DEFAULT_LEVEL_ID]
	return DATABASE[level_id]


static func get_level_name(level_id: String) -> String:
	return get_level(level_id)["name"]


static func get_scene_path(level_id: String) -> String:
	return get_level(level_id)["scene_path"]


static func get_planet_color(level_id: String) -> Color:
	return get_level(level_id)["planet_color"]
