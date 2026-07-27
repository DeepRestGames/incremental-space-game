extends Label


func _ready() -> void:
	EventBus.connect("player_enter_expedition_ship_area", on_enter_lobby_ship)
	EventBus.connect("player_exit_expedition_ship_area", hide)
	
	EventBus.connect("player_enter_expedition_return_area", on_enter_expedition_ship)
	EventBus.connect("player_exit_expedition_return_area", hide)
	
	EventBus.connect("player_enter_skill_terminal_area", on_enter_skill_terminal)
	EventBus.connect("player_exit_skill_terminal_area", hide)

	EventBus.connect("player_enter_shop_area", on_enter_shop)
	EventBus.connect("player_exit_shop_area", hide)

	hide()


func on_enter_lobby_ship() -> void:
	text = "Start expedition"
	show()


func on_enter_expedition_ship() -> void:
	text = "End expedition"
	show()


func on_enter_skill_terminal() -> void:
	text = "Access Skill Tree"
	show()


func on_enter_shop() -> void:
	text = "Sell resources"
	show()
