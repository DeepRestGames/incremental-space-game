@tool
class_name PlanetButton
extends Button

## One planet in the level select. Place it by hand: the planet image floats and
## lights up, while this button - the click area - stays exactly where you put it.

@export var level: LevelData:
	set(value):
		level = value
		if is_node_ready():
			_apply_level()

@export var float_height: float = 4.0
@export var float_period: float = 3.0
@export var lit_scale: float = 1.08

## Clickable circle as a fraction of the button's smaller side. Lower it for
## planets whose image has rings or empty space around the disc.
@export_range(0.1, 1.0) var hit_radius_ratio: float = 1.0

@onready var _planet: TextureRect = %Planet
@onready var _bracket: Control = %Bracket
@onready var _name_label: Label = %NameLabel

var _hovered := false
var _lit_tween: Tween


func _ready() -> void:
	toggle_mode = true
	_apply_level()
	_planet.resized.connect(_center_pivot)
	_center_pivot()
	_refresh_state()
	if Engine.is_editor_hint():
		return  # in the editor: show the planet, but no animations
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	toggled.connect(func(_on: bool): _refresh_state())
	_start_floating()


func _apply_level() -> void:
	_planet.texture = level.planet_texture if level else null
	_name_label.text = level.display_name if level else ""
	var playable := level != null and level.is_playable()
	disabled = not playable
	# Not focusable = the arrow keys skip it.
	focus_mode = Control.FOCUS_ALL if playable else Control.FOCUS_NONE
	_planet.modulate = Color.WHITE if playable else Color(0.5, 0.5, 0.5)


func _center_pivot() -> void:
	_planet.pivot_offset = _planet.size / 2


func _set_hovered(on: bool) -> void:
	_hovered = on
	_refresh_state()


## One function decides the whole look, from the current state only.
func _refresh_state() -> void:
	_bracket.visible = button_pressed
	_name_label.visible = button_pressed
	if Engine.is_editor_hint() or disabled:
		return
	var lit := button_pressed or _hovered
	if _lit_tween:
		_lit_tween.kill()
	_lit_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_lit_tween.tween_property(_planet, "scale", Vector2.ONE * (lit_scale if lit else 1.0), 0.15)
	_lit_tween.tween_property(_planet, "modulate", Color(1.3, 1.3, 1.3) if lit else Color.WHITE, 0.15)


func _start_floating() -> void:
	var base_y := _planet.position.y
	var t := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(_planet, "position:y", base_y - float_height, float_period * 0.5)
	t.tween_property(_planet, "position:y", base_y, float_period * 0.5)
	# Jump each planet to a random point of its cycle, so they don't bob in sync.
	t.custom_step(randf() * float_period)
	
	

## Only the round planet is clickable, not the button's square corners. A point
## outside the circle isn't "on" this button, so clicks and hover there fall
## through to whatever is underneath - e.g. a moon tucked against a big planet.
func _has_point(point: Vector2) -> bool:
	var radius := minf(size.x, size.y) * 0.5 * hit_radius_ratio
	return point.distance_to(size * 0.5) <= radius
