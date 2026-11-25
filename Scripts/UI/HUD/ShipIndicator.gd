@tool
extends Control

## Guides $Arrow along a squircle fitted to this Control's rectangle in HUD.tscn.

## 2.0 = pure oval, 5.0 = smooth rounded rectangle, 10.0 = nearly square.
@export_range(2.0, 12.0, 0.1) var squareness: float = 5.0:
	set(value):
		squareness = value
		queue_redraw() # updates live without reloading the scene
## Point on ExpeditionShip the arrow aims at ((0, 0) = boarding hatch/ramp).
@export var target_offset: Vector2 = Vector2.ZERO

var _ship: ExpeditionShip

@onready var arrow: Node2D = $Arrow


func _ready() -> void:
	# godot editor only
	if Engine.is_editor_hint():
		item_rect_changed.connect(queue_redraw)
		queue_redraw() 
		return
	# in game
	arrow.hide()


func _process(_delta: float) -> void:
	# skip while editing
	if Engine.is_editor_hint():
		return
	# do in game (redraw arrow pointing to ship)
	if not is_instance_valid(_ship):
		_ship = get_tree().get_first_node_in_group("ExpeditionShip") as ExpeditionShip

	arrow.visible = (GameManager.expedition_started
			and not GameManager.is_world_obscured()
			and _ship != null
			and not _ship.is_on_screen())
	if not arrow.visible:
		return

	var origin: Vector2 = size * 0.5
	var ship_local: Vector2 = (_ship.get_canvas_transform() * (_ship.global_position + target_offset)) - global_position
	var dir: Vector2 = ship_local - origin
	if dir.is_zero_approx():
		return

	arrow.position = _point_on_track(dir)
	arrow.rotation = dir.angle()


func _draw() -> void:
	# if NOT in editor (in game), skip
	if not Engine.is_editor_hint():
		return
	# Draw ellipsis where arrow resides
	var pts := PackedVector2Array()
	const STEPS := 96
	for i in range(STEPS + 1):
		var angle: float = TAU * float(i) / float(STEPS)
		pts.append(_point_on_track(Vector2.from_angle(angle)))
	draw_polyline(pts, Color(0.05, 0.95, 0.95, 0.6), 2.0, true)


## Projects `dir` (from this Control's center) onto the squircle boundary.
## Shared by _draw() and _process() so the editor preview and gameplay never disagree.
func _point_on_track(dir: Vector2) -> Vector2:
	# squircle
	var radii: Vector2 = size * 0.5
	if radii.x <= 0.0 or radii.y <= 0.0 or dir.is_zero_approx():
		return radii
	var nx: float = absf(dir.x) / radii.x
	var ny: float = absf(dir.y) / radii.y
	var dist: float = pow(pow(nx, squareness) + pow(ny, squareness), 1.0 / squareness)
	return radii + dir / dist
