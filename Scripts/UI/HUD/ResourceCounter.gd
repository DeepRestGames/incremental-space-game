extends Control


@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.update_HUD.connect(update_resource_counter_value)
	
	update_resource_counter_value()


func update_resource_counter_value() -> void:
	if GameManager.expedition_started:
		value.text = "%d/%d" % [GameManager.current_player_resource, GameManager.get_max_player_resource()]
	else:
		# The deposit box is not capped, so no maximum is shown outside expeditions.
		value.text = str(GameManager.current_deposit_box_resource)
