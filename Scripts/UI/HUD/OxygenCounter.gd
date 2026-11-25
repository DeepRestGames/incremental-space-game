extends HBoxContainer

## Segmented oxygen readout.

## Full on/off blinks each segment performs before emptying.
@export_range(1, 10) var blinks_per_segment: int = 3

@onready var pct_label: Label = $"VBoxContainer/Oxy_perc"
@onready var oxygen_bar: HBoxContainer = $Oxy
@onready var vignette = $"../VignetteAsphyxiating"
@onready var chromatic_aberration: ColorRect = $"../ChromaticAberration"


## How fast the effects chase their target. Higher = snappier. ~4.0 ≈ 1s to settle.
@export var effect_fade_rate: float = 4.0

var _vignette_target_a: float = 0.0
var _aberration_target: float = 0.0
var _aberration_current: float = 0.0
var _modulate_target: Color = Color(0.051, 0.949, 0.949)   # add this

func _process(delta: float) -> void:
	# Fraction of the remaining gap to close this frame. The exp() makes this
	# identical at 30fps and 240fps, unlike a flat lerp weight.
	var t: float = 1.0 - exp(-effect_fade_rate * delta)

	if not is_equal_approx(vignette.modulate.a, _vignette_target_a):
		vignette.modulate.a = lerpf(vignette.modulate.a, _vignette_target_a, t)

	if not is_equal_approx(_aberration_current, _aberration_target):
		_aberration_current = lerpf(_aberration_current, _aberration_target, t)
		chromatic_aberration.material.set_shader_parameter("intensity", _aberration_current)
		
	if not self.modulate.is_equal_approx(_modulate_target):
		self.modulate = self.modulate.lerp(_modulate_target, t)


func _ready() -> void:
	hide()
	vignette.hide()
	chromatic_aberration.hide()

	EventBus.update_oxygen_HUD.connect(on_update_oxygen)

	if GameManager.expedition_started:
		vignette.show()
		chromatic_aberration.show()
		
	_aberration_current = 0.0
	chromatic_aberration.material.set_shader_parameter("intensity", 0.0)
	vignette.modulate.a = 0.0
	self.modulate = _modulate_target
	
	EventBus.hud_booted.connect(_appear)


## Fades in instead of popping: _process already lerps modulate toward
## _modulate_target (alpha 1), so starting from 0 is all it takes.
func _appear() -> void:
	modulate.a = 0.0
	show()

func on_update_oxygen(current: float, max_val: float) -> void:
	var oxygen_ratio: float = clampf(current / max_val, 0.0, 1.0)
	pct_label.text = "%d" % roundi(oxygen_ratio * 100.0)
	
	#recolor based on oxygen %
	# -------------------------------------------------------------------------------
	if oxygen_ratio > 0.3:
		_modulate_target = Color(0.051, 0.949, 0.949)
		_vignette_target_a = 0.0
		_aberration_target = 0.0
	# --------------------------
	elif oxygen_ratio > 0.15:
		_modulate_target  = Color(0.949, 0.8, 0.051)
		_vignette_target_a = 0.4
		_aberration_target = 1.5
	# --------------------------
	else:
		_modulate_target = Color(0.933, 0.169, 0.345, 1.0)
		_vignette_target_a = 0.8
		_aberration_target = 2.5
	# -------------------------------------------------------------------------------
	_update_segments(oxygen_ratio)


func _update_segments(ratio: float) -> void:
	var total: int = oxygen_bar.get_child_count()
	var exact: float = ratio * float(total)
	var full: int = clampi(floori(exact), 0, total)

	for bar_index in total:
		var fill := _fill_of(bar_index)
		if fill:
			fill.modulate.a = 1.0 if bar_index < full else 0.0

	if full >= total or exact <= float(full):
		return

	var frontier := _fill_of(full)
	if not frontier:
		return

	# Odd number of half-waves (2N + 1): starts at 1.0 (was full), pulses on/off
	# `blinks_per_segment` times, and lands on 0.0 right as the tab empties.
	var drained: float = 1.0 - (exact - float(full))
	var half_waves: float = float(2 * blinks_per_segment + 1)
	frontier.modulate.a = 0.5 + 0.5 * cos(half_waves * PI * drained)

## Solid overlay of segment `index`
func _fill_of(index: int) -> TextureRect:
	var seg := oxygen_bar.get_child(index)
	# (the fill itself)
	if seg.get_child_count() == 0:
		return null
	# (the empty bar whose children is the fill)
	return seg.get_child(0) as TextureRect
