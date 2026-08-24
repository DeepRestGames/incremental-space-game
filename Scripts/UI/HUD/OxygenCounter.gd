extends HBoxContainer

## Segmented oxygen readout.

## Alpha the draining segment fades down to. 0.0 = full swap to the empty art
@export_range(0.0, 1.0) var pulse_min_alpha: float = 0.0
## Seconds for one complete pulse cycle
@export var pulse_time: float = 1.0

@onready var pct_label: Label = $"VBoxContainer/Oxy_perc"
@onready var oxygen_bar: HBoxContainer = $Oxy
@onready var vignette = $"../VignetteAsphyxiating"
@onready var chromatic_aberration: ColorRect = $"../ChromaticAberration"


## Fully-lit segments at the last update. -1 forces the first paint.
var _full_segments: int = -1
var _pulse_tween: Tween


func _ready() -> void:
	hide()
	vignette.hide()
	chromatic_aberration.hide()

	EventBus.update_oxygen_HUD.connect(on_update_oxygen)
	EventBus.expedition_started.connect(on_expedition_started)

	if GameManager.expedition_started:
		vignette.show()
		chromatic_aberration.show()
		show()




func on_update_oxygen(current: float, max_val: float) -> void:
	if not visible:
		show()
		
	var ratio: float = clampf(current / max_val, 0.0, 1.0)
	pct_label.text = "%d" % roundi(ratio * 100.0)
	
	#recolor based on oxygen %
	var vignette_tween = create_tween()
	var chromatic_aberration_tween = create_tween()
	if ratio > 0.5:
		self.modulate = Color(0.051, 0.949, 0.949)
		chromatic_aberration.material.set_shader_parameter("intensity", 0.0)
		
	elif ratio <= 0.3 && ratio > 0.15:
		vignette.modulate.a = 0
		self.modulate = Color(0.949, 0.8, 0.051)		
		vignette_tween.tween_property(vignette, "modulate:a", 0.4, 1.0)
		chromatic_aberration_tween.tween_method( func(value): 
			chromatic_aberration.material.set_shader_parameter("intensity", value), 
			chromatic_aberration.material.get_shader_parameter("intensity"), 2.0, 1.0)
		
	elif ratio <= 0.15:
		self.modulate = Color(0.933, 0.169, 0.345, 1.0)
		vignette_tween.tween_property(vignette, "modulate:a", 0.8, 1.0)
		chromatic_aberration_tween.tween_method( func(value): 
			chromatic_aberration.material.set_shader_parameter("intensity", value), 
			chromatic_aberration.material.get_shader_parameter("intensity"), 4.0, 1.0)
		
	

	
	
	var total: int = oxygen_bar.get_child_count()
	var should_be_full: int = clampi(floori(ratio * total), 0, total)

	# Called every frame by the Player, but the bar only changes once per segment.
	if should_be_full == _full_segments:
		return
	_full_segments = should_be_full

	_repaint(ratio, should_be_full, total)


func _repaint(ratio: float, full: int, total: int) -> void:
	# Kills the tween if it exists (previous bar)
	if _pulse_tween:
		_pulse_tween.kill()

	for bar_index in total:
		var fill := _fill_of(bar_index)
		if fill:
			fill.modulate.a = 1.0 if bar_index < full else 0.0

	# On an exact boundary
	if ratio * total <= float(full):
		return

	var frontier := _fill_of(full)
	if not frontier:
		return

	# Start
	frontier.modulate.a = 1.0

	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_trans(Tween.TRANS_EXPO)
	_pulse_tween.tween_property(frontier, "modulate:a", pulse_min_alpha, pulse_time * 0.15)
	_pulse_tween.tween_property(frontier, "modulate:a", 1.0, pulse_time * 0.15)
	_pulse_tween.tween_property(frontier, "modulate:a", 1.0, pulse_time * 0.6)


## Solid overlay of segment `index`
func _fill_of(index: int) -> TextureRect:
	var seg := oxygen_bar.get_child(index)
	# (the fill itself)
	if seg.get_child_count() == 0:
		return null
	# (the empty bar whose children is the fill)
	return seg.get_child(0) as TextureRect


func on_expedition_started() -> void:
	show()
