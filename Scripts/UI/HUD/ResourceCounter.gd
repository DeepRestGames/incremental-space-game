extends Control

## Cargo meter: how full the backpack is against the shared carrying capacity.
## Deliberately a total and not per-type - capacity is one limit across every
## resource, so the sum is the number that matters here.

## TODO: outside an expedition this used to show stored_total(), i.e. ore and
## money added together, which stopped meaning anything once they became
## different resources. For now the widget just hides itself. The replacement
## is one MoneyCounter node per resource you want on screen - that script
## already takes a ResourceType, so it needs no new code, only new nodes.

@onready var value = $HBoxContainer/Value


func _ready() -> void:
	EventBus.update_HUD.connect(_refresh)
	_refresh()


func _refresh() -> void:
	visible = GameManager.expedition_started
	if not visible:
		return
	value.text = "%d/%d" % [GameManager.carried_total(), GameManager.get_max_player_resource()]
