extends Label


func _ready() -> void:
	EventBus.connect("player_enter_expedition_ship_area", show)
	EventBus.connect("player_exit_expedition_ship_area", hide)
	
	EventBus.connect("expedition_started", on_expedition_started)
	EventBus.connect("expedition_ended", on_expedition_ended)
	
	on_expedition_ended()


func on_expedition_started() -> void:
	text = "Return to base"


func on_expedition_ended() -> void:
	text = "Start expedition"
