extends PanelContainer

## Diegetic `[ SHIP AI ]` radio banner: unzips from a center slit with static noise,
## reveals text via `visible_ratio`, holds, and collapses back into a slit.

const AI_NAME := "GRUMPYPETAL-AI"
const HEADER_NORMAL := ("[ %s // COMMS ]" % AI_NAME)
const HEADER_URGENT := ("[ %s // WARNING ]" % AI_NAME)
const COLOR_NORMAL := Color(0.051, 0.949, 0.949, 0.75)
const COLOR_URGENT := Color(0.933, 0.169, 0.345, 0.95)

@export_group("Timing")
@export var slit_width_time: float = 0.12
@export var slit_open_time: float = 0.18
@export var type_time: float = 0.45
@export var hold_time: float = 3.8
@export var close_time: float = 0.16
@export var static_flicker_interval: float = 0.06

var _tween: Tween
var _static_timer: float = 0.0

@onready var header_label: Label = %HeaderLabel
@onready var message_label: Label = %MessageLabel
@onready var static_noise: TextureRect = %StaticNoise
@onready var beep_player: AudioStreamPlayer = %BeepPlayer


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	EventBus.radio_message.connect(show_message)

	if get_tree().current_scene == self:
		# Standalone F6 demo so you can tune the slit & static right in this scene!
		position = Vector2(65.0, 145.0)
		show_message("Signal acquired. Hold Left Click to drill continuously.")
	else:
		hide()
		_on_visibility_changed()


func _on_visibility_changed() -> void:
	set_process(is_visible_in_tree())


func _process(delta: float) -> void:
	_static_timer += delta
	if _static_timer >= static_flicker_interval:
		_static_timer = 0.0
		static_noise.flip_h = randf() < 0.5
		static_noise.flip_v = randf() < 0.5


func show_message(text: String, urgent: bool = false) -> void:
	if _tween:
		_tween.kill()

	# Uses UI_theme's built-in DangerPanel variation for urgent alerts.
	theme_type_variation = &"DangerPanel" if urgent else &""
	header_label.text = HEADER_URGENT if urgent else HEADER_NORMAL
	header_label.modulate = COLOR_URGENT if urgent else COLOR_NORMAL

	message_label.text = text
	message_label.visible_ratio = 0.0
	show()
	reset_size()
	pivot_offset = size * 0.5

	# Start as a thin horizontal line in the middle with heavy static that clears as it opens.
	scale = Vector2(0.0, 0.04)
	static_noise.modulate.a = 0.35
	beep_player.pitch_scale = 1.15 if urgent else 1.55
	beep_player.play()

	_tween = create_tween()
	_tween.tween_property(self, "scale:x", 1.0, slit_width_time) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale:y", 1.0, slit_open_time) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(static_noise, "modulate:a", 0.12, slit_open_time)
	_tween.tween_property(message_label, "visible_ratio", 1.0, type_time)
	_tween.tween_interval(hold_time)
	_tween.tween_property(self, "scale:y", 0.04, close_time) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "scale:x", 0.0, slit_width_time * 0.8)
	_tween.tween_callback(hide)
