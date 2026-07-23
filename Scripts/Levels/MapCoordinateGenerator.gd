class_name MapCoordinateGenerator
extends Node

## 2D Coordinate Generator for Map Spawning
## Uses a Cluster Spawner approach with rejection sampling to generate clumpy spawn points.


## ----- ALGORITHM PARAMETERS -----
# TODO: Map size should ideally be inherited from the game/level scene (e.g., boundary rectangle or level width/height) instead of being hardcoded.
@export var map_size: Vector2 = Vector2(2000, 2000) ## The size of the map/arena in pixels.
@export var border_margin: float = 100.0            ## The padding margin from the map edges where objects cannot spawn.
@export var max_retries: int = 100                  ## Maximum retries to place a point near a seed before giving up on that specific attempt.
# TODO: We can make this map-bound (e.g. a map has more clustered, more spawn...
@export var min_distance: float = 80.0              ## The minimum distance required between any two successfully placed coordinates.
@export var min_spawn_count: int = 50               ## The range of coordinates (number of objects) to spawn.
@export var max_spawn_count: int = 150
@export var num_seeds: int = 6                      ## The number of "Seed" points around which actual objects will cluster.
@export var cluster_spread: float = 180.0           ## STD for Gaussian distribution around seeds (higher = more spread out, lower = tightly packed)
@export var center_safe_radius: float = 400.0      ## Safe zone radius around the center (where player spawns) where nothing can spawn.
@export var custom_exclusion_points: Array[Vector2] = [] ## Custom level-space exclusion points (e.g., ship, deposit box positions relative to center).
@export var custom_exclusion_radius: float = 400.0   ## Safe radius around custom exclusion points.
## / ----- ALGORITHM PARAMETERS -----

var spawn_distribution: Dictionary:
	get:
		var dist_node = get_node_or_null("SpawnDistribution")
		if dist_node:
			return dist_node.spawn_distribution
		return _spawn_distribution_fallback
	set(value):
		var dist_node = get_node_or_null("SpawnDistribution")
		if dist_node:
			dist_node.spawn_distribution = value
		else:
			_spawn_distribution_fallback = value

var _spawn_distribution_fallback: Dictionary = {}


# Cached weight distribution data
var _total_weight: float = 0.0
var _cumulative_weights: Array[float] = []
var _scenes_pool: Array[PackedScene] = []

## Runs the coordinate generation synchronously on the current thread.
## Returns an array of dictionaries in the format: [{"position": Vector2, "item": SpawnableItem}]
func generate_sync() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var accepted_positions: Array[Vector2] = []
	
	if spawn_distribution.is_empty():
		push_error("MapCoordinateGenerator: Spawning distribution is empty. Cannot generate coordinates.")
		return results
		
	# Select a random target count within the range
	var target_count := randi_range(min_spawn_count, max_spawn_count)
	
	# Generate seed points
	var seeds := _generate_seed_points()
	if seeds.is_empty():
		push_error("MapCoordinateGenerator: Failed to generate seed points. Check map_size and border_margin.")
		return results
		
	# Cache cumulative weights for selection
	_prepare_weight_distribution()
	
	var total_attempts := 0
	var budget_limit := target_count * max_retries
	
	while accepted_positions.size() < target_count:
		var seed_point: Vector2 = seeds.pick_random()
		var placed := false
		
		for retry in range(max_retries):
			total_attempts += 1
			
			# Generate offset using Gaussian radius and random angle
			var angle: float = randf_range(0.0, TAU)
			var radius: float = abs(_rand_normal(0.0, cluster_spread))
			var offset: Vector2 = Vector2.from_angle(angle) * radius
			var pos: Vector2 = seed_point + offset
			
			if _is_position_valid(pos, accepted_positions):
				var selected_scene := _pick_weighted_item()
				accepted_positions.append(pos)
				results.append({
					"position": pos,
					"scene": selected_scene
				})
				placed = true
				break
				
		# Prevent infinite loops if map is too full or constraints are too strict
		if not placed and total_attempts > budget_limit:
			push_warning("MapCoordinateGenerator: Generation budget exceeded. Placed %d/%d items." % [accepted_positions.size(), target_count])
			break
			
	return results


# Helper: Generate seed coordinates inside the valid bounds
func _generate_seed_points() -> Array[Vector2]:
	var seeds: Array[Vector2] = []
	var min_x := border_margin
	var max_x := map_size.x - border_margin
	var min_y := border_margin
	var max_y := map_size.y - border_margin
	
	if min_x >= max_x or min_y >= max_y:
		return seeds
		
	for i in range(num_seeds):
		var seed_pos := Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		seeds.append(seed_pos)
	return seeds


# Helper: Validate that a candidate position satisfies map boundary and distance checks
func _is_position_valid(pos: Vector2, accepted_positions: Array[Vector2]) -> bool:
	# Border boundary check
	if pos.x < border_margin or pos.x > map_size.x - border_margin:
		return false
	if pos.y < border_margin or pos.y > map_size.y - border_margin:
		return false
		
	# Center safe zone check (prevent spawning on player at level center)
	if center_safe_radius > 0.0:
		var center := map_size / 2.0
		if pos.distance_squared_to(center) < center_safe_radius * center_safe_radius:
			return false
			
	# Custom exclusion zones check (prevent spawning on ship/deposit box)
	if not custom_exclusion_points.is_empty():
		var excl_radius_sq := custom_exclusion_radius * custom_exclusion_radius
		for excl_pos in custom_exclusion_points:
			var generator_excl_pos := excl_pos + (map_size / 2.0)
			if pos.distance_squared_to(generator_excl_pos) < excl_radius_sq:
				return false
		
	# Minimum spacing check (squared comparison for performance)
	var min_dist_sq := min_distance * min_distance
	for accepted_pos in accepted_positions:
		if pos.distance_squared_to(accepted_pos) < min_dist_sq:
			return false
			
	return true


# Helper: Standard Normal (Gaussian) distribution generator using Box-Muller transform
func _rand_normal(mean: float, stddev: float) -> float:
	var u1 := maxf(randf(), 1e-7)
	var u2 := randf()
	
	var r := sqrt(-2.0 * log(u1))
	var theta := TAU * u2
	return mean + stddev * r * cos(theta)


# Helper: Build cumulative weight array for fast selection
func _prepare_weight_distribution() -> void:
	_total_weight = 0.0
	_cumulative_weights.clear()
	_scenes_pool.clear()
	
	for scene in spawn_distribution:
		if scene is PackedScene:
			var weight: float = spawn_distribution[scene]
			_total_weight += max(weight, 0.0)
			_cumulative_weights.append(_total_weight)
			_scenes_pool.append(scene)


# Helper: Weighted pick of a PackedScene
func _pick_weighted_item() -> PackedScene:
	if _scenes_pool.is_empty() or _total_weight <= 0.0:
		return null
		
	var r := randf_range(0.0, _total_weight)
	for i in range(_cumulative_weights.size()):
		if r <= _cumulative_weights[i]:
			return _scenes_pool[i]
			
	return _scenes_pool.back()
