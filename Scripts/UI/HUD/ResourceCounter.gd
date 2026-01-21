extends Control


@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.connect("update_HUD", update_resource_counter_value)
	
	update_resource_counter_value()


func update_resource_counter_value() -> void:
	value.text = str(GameManager.current_player_resource)
