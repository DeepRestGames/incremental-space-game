class_name LevelDB

## Read-only database of every playable level, keyed by level id.
##
## Same role as SkillDB: the single place where level data lives. Nothing writes
## to it at runtime (it is a const, so Godot enforces that) - LevelSelectUI keeps
## the values it computes per run in its own dictionary instead.

const PLANET_PATH: String = "res://Scenes/Levels/Planets/"

const DATABASE: Dictionary = {
	"moon_1234": {
		"name": "MOON 1",
		"scene_path": PLANET_PATH + "Moon1.tscn",
		"planet_color": Color(0.15, 0.268, 0.321, 1.0)
	},
	"nebula_alpha": {
		"name": "MOON 2",
		"scene_path": PLANET_PATH + "Moon2.tscn",
		"planet_color": Color(0.712, 0.253, 0.582, 1.0)
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
