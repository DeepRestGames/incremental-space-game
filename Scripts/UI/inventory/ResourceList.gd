class_name ResourceList
extends GridContainer

const SLOT := preload("res://Scenes/UI/inventory/ResourceSlot.tscn")


## Rebuilds the list from `amounts`, in ResourceDB.ALL order.
## `filter` gets (type, amount) and returns true to show that slot.
func show_resources(amounts: Dictionary, filter: Callable, format: Callable = Callable()) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for t in ResourceDB.ALL:
		var amount: int = amounts.get(t.id, 0)
		if not filter.call(t, amount):
			continue
		var slot: ResourceSlot = SLOT.instantiate()
		add_child(slot)
		slot.setup(t, format.call(t, amount) if format.is_valid() else str(amount))
