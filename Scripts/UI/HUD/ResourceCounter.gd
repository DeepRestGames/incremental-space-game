extends Control


@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.connect("update_HUD", update_resource_counter_value)
	
	update_resource_counter_value()


func update_resource_counter_value() -> void:
	if GameManager.expedition_started:
		value.text = str(GameManager.current_player_resource)
	else:
		value.text = str(GameManager.current_deposit_box_resource)
