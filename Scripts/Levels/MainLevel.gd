extends Node2D

## Main Level script that handles dynamic spawning of environment objects
## using the MapCoordinateGenerator.

@onready var coordinate_generator: MapCoordinateGenerator = $MapCoordinateGenerator

func _ready() -> void:
	# Fallback configuration in code if the array is empty in the Inspector
	if coordinate_generator.spawn_distribution.is_empty():
		_setup_default_spawnable_items()
		
	spawn_level_objects()


func _setup_default_spawnable_items() -> void:
	var small_scene = load("res://Scenes/Environment/breakable_small.tscn")
	var big_scene = load("res://Scenes/Environment/breakable_big.tscn")
	coordinate_generator.spawn_distribution = {
		small_scene: 8.0,
		big_scene: 2.0
	}


func spawn_level_objects() -> void:
	var start_time := Time.get_ticks_msec()
	
	var spawn_points := coordinate_generator.generate_sync()
	var map_size := coordinate_generator.map_size
	
	var spawned_count := 0
	for point in spawn_points:
		var pos: Vector2 = point.position
		var scene: PackedScene = point.scene
		
		if scene == null:
			continue
			
		var instance := scene.instantiate() as Node2D
		
		# Translate generator top-left (0 to map_size) coords to centered level coords (-map_size/2 to +map_size/2)
		instance.global_position = pos - (map_size / 2.0)
		
		add_child(instance)
		spawned_count += 1
		
	var duration := Time.get_ticks_msec() - start_time
	print("[MainLevel] Dynamically spawned %d objects in %d ms." % [spawned_count, duration])
