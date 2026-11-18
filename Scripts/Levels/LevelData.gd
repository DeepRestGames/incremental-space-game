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

#region layers
## Layers under the surface, top to bottom: depth 1 is layer_paths[0].
## Each one is a scene that inherits BaseLevel, exactly like the surface.
@export_file("*.tscn") var layer_paths: Array[String] = []

## Scene for a depth: 0 = surface, 1 = first layer below, ...
## Empty string if the planet doesn't go that deep.
func get_scene_path_at(depth: int) -> String:
	if depth == 0:
		return scene_path
	if depth < 0 or depth > layer_paths.size():
		return ""
	return layer_paths[depth - 1]


func has_layer_below(depth: int) -> bool:
	return get_scene_path_at(depth + 1) != ""
#endregion

## Shown in the level select either way; only playable ones can be picked.
func is_playable() -> bool:
	return scene_path != ""
