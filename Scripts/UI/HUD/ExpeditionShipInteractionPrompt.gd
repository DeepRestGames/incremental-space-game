extends Label


func _ready() -> void:
	EventBus.connect("player_enter_expedition_ship_area", on_enter_lobby_ship)
	EventBus.connect("player_exit_expedition_ship_area", hide)
	
	EventBus.connect("player_enter_expedition_return_area", on_enter_expedition_ship)
	EventBus.connect("player_exit_expedition_return_area", hide)
	
	hide()


func on_enter_lobby_ship() -> void:
	text = "Start expedition"
	show()


func on_enter_expedition_ship() -> void:
	text = "Return to base"
	show()
