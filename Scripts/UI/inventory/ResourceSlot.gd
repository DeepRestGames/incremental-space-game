class_name ResourceSlot
extends PanelContainer

## One square in a ResourceList: the resource's icon, with the amount in the
## bottom-right corner. No name - that will live in the hover tooltip.

@onready var _icon: TextureRect = %Icon
@onready var _amount: Label = %Amount

## Kept for the hover tooltip later: the slot no longer shows a name, but the
## tooltip will need to know what it's showing.
var type: ResourceType


func setup(t: ResourceType, amount_text: String) -> void:
	type = t
	_icon.texture = t.icon
	_amount.text = amount_text
