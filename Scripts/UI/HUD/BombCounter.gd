extends Control

@onready var pct_label: Label = $HBoxContainer/Value
@onready var texture_rect: TextureRect = $HBoxContainer/BombIcon

func _ready() -> void:
	hide()
	EventBus.update_bomb_HUD.connect(on_update_bomb)
	EventBus.expedition_started.connect(on_expedition_started)
	
	if GameManager.expedition_started:
		# Query starting values if already running in a debug scene
		var player = GameManager.player
		if player and "current_bombs" in player:
			on_update_bomb(player.current_bombs, player.max_bombs)


func on_update_bomb(current: int, max_val: int) -> void:
	if max_val <= 0:
		hide()
		return
		
	if GameManager.expedition_started:
		show()
		if pct_label:
			pct_label.text = "%d/%d" % [current, max_val]
	else:
		hide()


func on_expedition_started() -> void:
	hide()
