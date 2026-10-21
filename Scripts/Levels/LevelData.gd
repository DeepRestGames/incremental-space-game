@tool
class_name LevelData
extends Resource

## How a planet appears in the level select, and which scene it loads.

@export var id: StringName
@export var display_name: String
## A path, not a PackedScene: a PackedScene field would load the whole planet
## (and everything in it) the moment LevelDB is first touched.
@export_file("*.tscn") var scene_path: String
@export var planet_texture: Texture2D


## Shown in the level select either way; only playable ones can be picked.
func is_playable() -> bool:
	return scene_path != ""
