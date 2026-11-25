extends Control

## Visual tunnel played between underground planet layers.
## Layout, walls, and wind particles live in DescentCutscene.tscn; this script
## wobbles the rigs around wherever they are placed in the 2D editor.

@export_group("Wiggle")
@export var player_wobble_px: float = 14.0
@export var player_tilt_wobble_deg: float = 6.0
@export var ship_sway_px: float = 7.0
## High-frequency shudder so the heavy drill pod feels powered.
@export var ship_vibration_px: float = 2.5

@export_group("Timing")
@export var enter_fade_duration: float = 0.25
@export var enter_drop_duration: float = 0.45
@export var hold_duration: float = 1.4
@export var exit_drop_duration: float = 0.40
@export var exit_fade_duration: float = 0.25

var _time: float = 0.0
## Extra vertical offset tweened during enter/exit (7.3); 0 during F6 preview.
var _rig_offset_y: float = 0.0

var _drop_tween: Tween

var _player_base_pos: Vector2
var _player_base_rot: float
var _ship_base_pos: Vector2
var _ship_base_rot: float

@onready var player_rig: Node2D = %PlayerRig
@onready var ship_rig: Node2D = %ShipRig


func _ready() -> void:
	_player_base_pos = player_rig.position
	_player_base_rot = player_rig.rotation_degrees
	_ship_base_pos = ship_rig.position
	_ship_base_rot = ship_rig.rotation_degrees

	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	set_process(is_visible_in_tree())



## Fades the shaft in while dropping both rigs into view from above.
## Returns as soon as the screen is fully opaque so the scene can swap behind it.
func play_enter() -> void:
	if _drop_tween:
		_drop_tween.kill()
	_rig_offset_y = -700.0
	modulate.a = 0.0
	show()
	_update_rigs()

	_drop_tween = create_tween()
	_drop_tween.tween_property(self, "_rig_offset_y", 0.0, enter_drop_duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var fade_tween := create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, enter_fade_duration)
	await fade_tween.finished


## Holds the freefall, then plunges both rigs out the bottom while fading out.
func play_hold_and_exit() -> void:
	var hold_tween := create_tween()
	hold_tween.tween_interval(hold_duration)
	await hold_tween.finished

	if _drop_tween:
		_drop_tween.kill()
	_drop_tween = create_tween().set_parallel()
	_drop_tween.tween_property(self, "_rig_offset_y", 850.0, exit_drop_duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_drop_tween.tween_property(self, "modulate:a", 0.0, exit_fade_duration) \
			.set_delay(maxf(exit_drop_duration - exit_fade_duration, 0.0))
	await _drop_tween.finished

	hide()
	_rig_offset_y = 0.0
	modulate.a = 1.0

func _process(delta: float) -> void:
	_time += delta
	_update_rigs()


func _update_rigs() -> void:
	# Two non-integer frequency ratios keep the freefall wobble from feeling like a metronome.
	var player_wobble := Vector2(
		sin(_time * 5.3) * 0.7 + sin(_time * 8.7) * 0.3,
		cos(_time * 4.1) * 0.7 + sin(_time * 7.3) * 0.3
	) * player_wobble_px
	player_rig.position = _player_base_pos + Vector2(0.0, _rig_offset_y) + player_wobble
	player_rig.rotation_degrees = _player_base_rot + sin(_time * 6.1) * player_tilt_wobble_deg

	# Slow drift plus fast drill vibration.
	var ship_sway := Vector2(
		sin(_time * 2.9) * ship_sway_px,
		cos(_time * 2.3) * ship_sway_px * 1.4
	)
	var ship_shudder := Vector2(
		sin(_time * 43.0),
		cos(_time * 37.0)
	) * ship_vibration_px
	ship_rig.position = _ship_base_pos + Vector2(0.0, _rig_offset_y) + ship_sway + ship_shudder
	ship_rig.rotation_degrees = _ship_base_rot + sin(_time * 3.4) * 2.0
