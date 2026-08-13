extends Control


@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.update_HUD.connect(update_money_counter_value)

	update_money_counter_value()


func update_money_counter_value() -> void:
	value.text = str(GameManager.current_money)
