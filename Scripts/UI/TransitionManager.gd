extends CanvasLayer

#region Signals
signal started
signal occlusion_reached
signal finished
#endregion
#region Definitions
#endregion
#region Constants
#endregion
#region Static Variables
#endregion
#region @export Variables
@export_group("Dots", "dots")
@export var dots_transition_duration: float = 1
#endregion
#region Regular Variables
var _transition_tween: Tween
#endregion
#region @onready Variables
@onready var dots: Control = $Dots
@onready var dots_begin: ColorRect = $Dots/DotsBegin
@onready var dots_end: ColorRect = $Dots/DotsEnd
@onready var audio_stream_player_out: AudioStreamPlayer = $AudioStreamPlayer_out
@onready var audio_stream_player_in: AudioStreamPlayer = $AudioStreamPlayer_in
#endregion

#region Event Methods
func _ready() -> void:
	_reset()
#endregion
#region Signal Handlers
#endregion

#region New tranisition stuff
## Pause → occlude → swap scene → reveal → unpause.
## Callers use this instead of calling change_scene_to_file themselves.
func change_scene(path: String) -> void:
	if GameManager.transitioning:
		push_warning("TransitionManager: a transition is already running, ignoring '%s'." % path)
		return
	GameManager.transitioning = true
	GameManager.game_paused = true

	transition_dots_begin()
	await occlusion_reached

	var previous := get_tree().current_scene
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("TransitionManager: could not load '%s' (error %d)." % [path, err])
	else:
		# change_scene_to_file is deferred, so wait for the swap to actually
		# land. Otherwise the reveal uncovers the scene we are leaving.
		while get_tree().current_scene == previous:
			await get_tree().process_frame

	transition_dots_end()
	await finished

	GameManager.game_paused = false
	GameManager.transitioning = false
#endregion

#region Regular Methods
func transition_dots_begin():
	_prepare_transition(dots_begin)
	
	audio_stream_player_out.play()
	dots.show()
	
	
	started.emit()
	_transition_tween = create_tween()
	_transition_tween.tween_method(
		_set_normalized_transition_progress.bind(dots_begin), \
		0.0, 1.0, dots_transition_duration)
	_transition_tween.tween_callback(occlusion_reached.emit)

func transition_dots_end():
	_prepare_transition(dots_end)
	
	dots.show()
	audio_stream_player_in.play()
	
	_transition_tween = create_tween()
	_transition_tween.tween_method(
		_set_normalized_transition_progress.bind(dots_end), \
		1.0, 0.0, dots_transition_duration)
	_transition_tween.tween_callback(dots.hide)
	_transition_tween.tween_callback(finished.emit)


func _reset():
	_set_normalized_transition_progress(0, dots_begin)
	_set_normalized_transition_progress(1, dots_end)
	
	if _transition_tween != null: _transition_tween.kill()


func _prepare_transition(transition: CanvasItem):
	_reset()
	_show_transition(transition)


func _show_transition(transition: CanvasItem):
	dots_begin.visible = dots_begin == transition
	dots_end.visible = dots_end == transition


func _set_normalized_transition_progress(progress: float, transition: CanvasItem):
	transition.material.set("shader_parameter/factor", progress)
#endregion
