extends Node

@onready var player_a = AudioStreamPlayer.new()
@onready var player_b = AudioStreamPlayer.new()

var current_player : AudioStreamPlayer
var next_player : AudioStreamPlayer

var fade_time := 1.5
var current_track : String = ""
var _fade_tween: Tween

func _ready():
	add_child(player_a)
	add_child(player_b)

# Send both players to Music bus
	player_a.bus = "Music"
	player_b.bus = "Music"

	current_player = player_a
	next_player = player_b
	
	# Start silent
	current_player.volume_db = 0
	next_player.volume_db = -80
	
func play(stream: AudioStream, track_id: String):
# Prevent restarting same track
	if track_id == current_track:
		return
	current_track = track_id

# Prepare next track
	next_player.stream = stream
	next_player.volume_db = -80
	next_player.play()

# Crossfade

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.tween_property(current_player, "volume_db", -80, fade_time)
	_fade_tween.tween_property(next_player, "volume_db", 0, fade_time)
	_fade_tween.chain().tween_callback(_swap_players)
	

func _swap_players():
	current_player.stop()

	var temp = current_player
	current_player = next_player
	next_player = temp
