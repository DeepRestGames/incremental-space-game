extends HBoxContainer

## Segmented oxygen readout.

## Alpha the draining segment fades down to. 0.0 = full swap to the empty art
@export_range(0.0, 1.0) var pulse_min_alpha: float = 0.0
## Seconds for one complete pulse cycle
@export var pulse_time: float = 1.0

@onready var pct_label: Label = $"VBoxContainer/Oxy_perc"
@onready var oxygen_bar: HBoxContainer = $Oxy

## Fully-lit segments at the last update. -1 forces the first paint.
var _full_segments: int = -1
var _pulse_tween: Tween


func _ready() -> void:
	hide()

	EventBus.update_oxygen_HUD.connect(on_update_oxygen)
	EventBus.expedition_started.connect(on_expedition_started)

	if GameManager.expedition_started:
		show()




func on_update_oxygen(current: float, max_val: float) -> void:
	if not visible:
		show()

	var ratio: float = clampf(current / max_val, 0.0, 1.0)
	pct_label.text = "%d" % roundi(ratio * 100.0)

	# Segment count comes from the scene and the fill from a ratio, so this works
	# for any number of segments and any oxygen tank capacity.
	var total: int = oxygen_bar.get_child_count()
	var full: int = clampi(floori(ratio * total), 0, total)

	# Called every frame by the Player, but the bar only changes once per segment.
	if full == _full_segments:
		return
	_full_segments = full

	_repaint(ratio, full, total)


func _repaint(ratio: float, full: int, total: int) -> void:
	if _pulse_tween:
		_pulse_tween.kill()

	for i in total:
		var fill := _fill_of(i)
		if fill:
			fill.modulate.a = 1.0 if i < full else 0.0

	# A segment only pulses while it is partly drained. On an exact boundary
	# (70% of ten segments) seven are solid and nothing is mid-drain; at zero
	# oxygen nothing is lit at all.
	if ratio * total <= float(full):
		return

	var frontier := _fill_of(full)
	if not frontier:
		return

	# The draining segment still holds oxygen, so it starts lit and dips from
	# there. Without this it would begin at 0.0 and waste the first half-cycle
	# fading from empty to empty.
	frontier.modulate.a = 1.0

	# Bound to this node, held in a member, and killed above before being
	# replaced: the three conditions that make an endless loop safe.
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(frontier, "modulate:a", pulse_min_alpha, pulse_time * 0.5)
	_pulse_tween.tween_property(frontier, "modulate:a", 1.0, pulse_time * 0.5)


## Solid overlay of segment `index`. The segment itself always shows the empty
## art; only this child's alpha moves.
func _fill_of(index: int) -> TextureRect:
	var seg := oxygen_bar.get_child(index)
	if seg.get_child_count() == 0:
		return null
	return seg.get_child(0) as TextureRect


func on_expedition_started() -> void:
	show()
