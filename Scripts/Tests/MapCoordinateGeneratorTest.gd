extends Node2D

## Visual Test Harness for the 2D Map Coordinate Generator
## Allows testing synchronous, yielding (async), and threaded modes with visual feedback.

var generator: MapCoordinateGenerator
var generated_points: Array[Dictionary] = []
var seed_points_for_draw: Array[Vector2] = []
var generation_time: float = 0.0
var generation_active: bool = false
var _start_time_usec: int = 0

# UI Label reference
var label: Label

func _ready() -> void:
	# Create CanvasLayer for UI text overlay
	var canvas_layer := CanvasLayer.new()
	add_child(canvas_layer)
	
	label = Label.new()
	label.position = Vector2(25, 25)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	canvas_layer.add_child(label)
	
	# Instantiate our coordinate generator
	generator = MapCoordinateGenerator.new()
	add_child(generator)
	
	# Dynamically set map size to fit the viewport dimensions
	var viewport_size := get_viewport_rect().size
	if viewport_size == Vector2.ZERO:
		viewport_size = Vector2(1152, 648)
	generator.map_size = viewport_size
	
	# Configure default parameters
	generator.border_margin = 60.0
	generator.min_distance = 35.0
	generator.min_spawn_count = 100
	generator.max_spawn_count = 180
	generator.num_seeds = 6
	generator.cluster_spread = 150.0
	
	# Define spawnable breakable resources programmatically
	var small_scene = load("res://Scenes/Environment/breakable_small.tscn")
	var big_scene = load("res://Scenes/Environment/breakable_big.tscn")
	generator.spawn_distribution = {
		small_scene: 8.0,
		big_scene: 2.0
	}
	
	# Run initial generation
	run_generation()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				run_generation() # Sync Spawning


func run_generation() -> void:
	if generation_active:
		return
	generation_active = true
	
	_start_time_usec = Time.get_ticks_usec()
	generated_points.clear()
	seed_points_for_draw.clear()
	
	# Immediately update screen to draw blank/updating state
	queue_redraw()
	
	generated_points = generator.generate_sync()
	_finalize_generation()


func _finalize_generation() -> void:
	generation_time = (Time.get_ticks_usec() - _start_time_usec) / 1000.0
	
	# Expose seed points for visualization
	seed_points_for_draw = generator._generate_seed_points()
	
	generation_active = false
	update_ui()
	queue_redraw()


func update_ui() -> void:
	var small_count := 0
	var big_count := 0
	for pt in generated_points:
		var scene: PackedScene = pt.scene
		if scene and scene.resource_path.contains("breakable_small"):
			small_count += 1
		elif scene and scene.resource_path.contains("breakable_big"):
			big_count += 1
			
	var total := generated_points.size()
	var pct_small := (float(small_count) / total * 100.0) if total > 0 else 0.0
	var pct_big := (float(big_count) / total * 100.0) if total > 0 else 0.0
	
	var text := "=== 2D MAP COORDINATE GENERATOR TEST  ===\n"
	text += "Press keys to generate:\n"
	text += "  [SPACE] - Generate (Sync Spawning)\n\n"
	text += "Current Mode: Sync Spawning\n"
	text += "Status: %s\n" % ("GENERATING..." if generation_active else "IDLE")
	
	if not generation_active:
		text += "Generated Items: %d\n" % total
		text += "  - Small Breakables: %d (%.1f%%, target weight: 80%%)\n" % [small_count, pct_small]
		text += "  - Big Breakables: %d (%.1f%%, target weight: 20%%)\n" % [big_count, pct_big]
		text += "Time Taken: %.3f ms\n" % generation_time
		
	label.text = text


func _draw() -> void:
	var min_bound := Vector2(generator.border_margin, generator.border_margin)
	var max_bound := generator.map_size - Vector2(generator.border_margin, generator.border_margin)
	var size_bound := max_bound - min_bound
	
	# Draw background bounds box
	draw_rect(Rect2(min_bound, size_bound), Color(0.12, 0.12, 0.15), true)
	draw_rect(Rect2(min_bound, size_bound), Color(0.3, 0.3, 0.35), false, 2.0)
	
	if generation_active:
		return
		
	# Draw cluster seeds and their range circles
	for seed_pt in seed_points_for_draw:
		draw_circle(seed_pt, 6.0, Color(0.0, 0.8, 1.0))
		draw_circle(seed_pt, generator.cluster_spread, Color(0.0, 0.8, 1.0, 0.05), false, 1.0, true)
		
	# Draw generated coordinates
	for pt in generated_points:
		var pos: Vector2 = pt.position
		var scene: PackedScene = pt.scene
		
		if scene == null:
			continue
			
		if scene.resource_path.contains("breakable_small"):
			# Draw Small Breakable (Emerald green circle)
			draw_circle(pos, 8.0, Color(0.08, 0.75, 0.45))
			draw_circle(pos, 8.0, Color.WHITE, false, 1.0)
		else:
			# Draw Big Breakable (Coral red circle)
			draw_circle(pos, 16.0, Color(0.95, 0.35, 0.25))
			draw_circle(pos, 16.0, Color.WHITE, false, 1.5)
