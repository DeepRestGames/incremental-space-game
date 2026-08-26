extends TextureRect

## Visor boot animation played at the start of an expedition: the visor drops in,
## then the display flickers as it comes up.
##
## The whole sequence is one Tween rather than a chain of awaited timers. That is
## not only tidier: SceneTree timers keep running while the game is paused
## (process_always defaults to true) whereas tweens do not, so a mixed
## timer/tween sequence desynchronises across any pause - such as the one a
## screen transition holds.

const VISOR_CLOSED := preload("res://Assets/UI/HUD_mockup_clean_1.png")
const VISOR_OPEN   := preload("res://Assets/UI/HUD_mockup_clean_2.png")
const VISOR_ACTIVE := preload("res://Assets/UI/HUD_mockup_clean_3.png")

## Y position the visor settles at once it has dropped in.
const RESTING_Y := -45.0
## Y position it starts from, above the screen.
const START_Y := -2000.0


func _ready() -> void:
	visible = false

	if not GameManager.expedition_started:
		return

	# Play to the player, not to the back of a transition wipe. This node is
	# PROCESS_MODE_INHERIT, so the pause a transition holds would freeze the
	# slide while leaving nothing to see once the reveal finished.
	if GameManager.transitioning:
		await TransitionManager.finished

	_play_boot_sequence()


## Absolute timings, measured from the start of the sequence:
##   0.00  visor starts dropping
##   0.70  visor settled
##   0.90  view opens
##   0.95  flicker off
##   1.05  flicker back on
func _play_boot_sequence() -> void:
	texture = VISOR_CLOSED
	position.y = START_Y
	visible = true

	# create_tween(), not get_tree().create_tween(): bound to this node, so it
	# dies with the HUD instead of writing to a freed object after a scene change.
	var tween := create_tween()

	# Lower the visor.
	tween.tween_property(self, "position:y", RESTING_Y, 0.7) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)

	# Open the view.
	tween.tween_interval(0.2)
	tween.tween_callback(_set_texture.bind(VISOR_OPEN))

	# Flicker.
	tween.tween_interval(0.05)
	tween.tween_callback(_set_texture.bind(VISOR_CLOSED))
	tween.tween_interval(0.1)
	tween.tween_callback(_set_texture.bind(VISOR_OPEN))

	# Activate the HUD. Disabled for now; uncomment to extend the sequence.
	#tween.tween_interval(0.4)
	#tween.tween_callback(_set_texture.bind(VISOR_ACTIVE))
	#tween.tween_interval(0.05)
	#tween.tween_callback(_set_texture.bind(VISOR_OPEN))
	#tween.tween_interval(0.1)
	#tween.tween_callback(_set_texture.bind(VISOR_ACTIVE))


func _set_texture(tex: Texture2D) -> void:
	texture = tex
