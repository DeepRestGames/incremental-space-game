extends Control

## Shows how much of one currency the player has banked.
## Which currency is a scene decision: drop a different ResourceType in the
## slot and this same widget becomes a counter for that one.
@export var resource_type: ResourceType

@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.update_HUD.connect(update_money_counter_value)

	update_money_counter_value()


func update_money_counter_value() -> void:
	if not resource_type:
		push_error("%s: no resource_type assigned" % name)
		return
	value.text = str(GameManager.stored_resources.get(resource_type.id, 0))
