class_name ResourceRow
extends HBoxContainer

@onready var _icon: TextureRect = $Icon
@onready var _name: Label = $Name
@onready var _amount: Label = $Amount


func setup(type: ResourceType, amount: int) -> void:
	_icon.texture = type.icon
	_name.text = type.display_name
	_amount.text = str(amount)
