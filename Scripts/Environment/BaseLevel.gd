class_name BaseLevel
extends Node2D

## Base Level class that handles common environment elements
## and dynamic spawning using the MapCoordinateGenerator.

@onready var coordinate_generator: MapCoordinateGenerator = $MapCoordinateGenerator

func _ready() -> void:
	# Gather dynamic positions of central structures as spawning exclusion zones
	var exclusions: Array[Vector2] = []
	for node_name in ["ExpeditionShip", "DepositBox", "CaptureArea"]:
		var structure := get_node_or_null(node_name) as Node2D
		if structure:
			exclusions.append(structure.position)
	coordinate_generator.custom_exclusion_points = exclusions

	# Fallback configuration in code if the array is empty in the Inspector
	if coordinate_generator.spawnable_items.is_empty():
		_setup_default_spawnable_items()
		
	spawn_level_objects()


func _setup_default_spawnable_items() -> void:
	var item_small := SpawnableItem.new()
	item_small.name = "Small Breakable"
	item_small.weight = 8.0 # 80% small rocks
	item_small.scene = load("res://Scenes/Environment/breakable_small.tscn")
	
	var item_big := SpawnableItem.new()
	item_big.name = "Big Breakable"
	item_big.weight = 2.0 # 20% big rocks
	item_big.scene = load("res://Scenes/Environment/breakable_big.tscn")
	
	coordinate_generator.spawnable_items = [item_small, item_big]


func spawn_level_objects() -> void:
	var start_time := Time.get_ticks_msec()
	
	var spawn_points := coordinate_generator.generate_sync()
	var map_size := coordinate_generator.map_size
	
	var spawned_count := 0
	for point in spawn_points:
		var pos: Vector2 = point.position
		var item: SpawnableItem = point.item
		
		if item == null or item.scene == null:
			continue
			
		var instance := item.scene.instantiate() as Node2D
		
		# Translate generator top-left (0 to map_size) coords to centered level coords (-map_size/2 to +map_size/2)
		instance.global_position = pos - (map_size / 2.0)
		
		add_child(instance)
		spawned_count += 1
		
	var duration := Time.get_ticks_msec() - start_time
	print("[%s] Dynamically spawned %d objects in %d ms." % [name, spawned_count, duration])
