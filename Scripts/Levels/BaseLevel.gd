class_name BaseLevel
extends Node2D

## Base Level class that handles common environment elements
## and dynamic spawning using the MapCoordinateGenerator.

@onready var objects: Node2D = $Objects
@onready var coordinate_generator: MapCoordinateGenerator = $Objects/MapCoordinateGenerator



func _ready() -> void:
#	MusicManager.play(preload("res://Assets/Audio/ST/ST_Expedition.wav"), "expedition")
	# Gather dynamic positions of central structures as spawning exclusion zones
	var exclusions: Array[Vector2] = []
	for node_name in ["ExpeditionShip", "DepositBox", "CaptureArea"]:
		var structure := get_node_or_null(node_name) as Node2D
		if structure:
			exclusions.append(structure.position)
	coordinate_generator.custom_exclusion_points = exclusions

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
		
		objects.add_child(instance)
		spawned_count += 1
		
	var duration := Time.get_ticks_msec() - start_time
	print("[%s] Dynamically spawned %d objects in %d ms." % [name, spawned_count, duration])
