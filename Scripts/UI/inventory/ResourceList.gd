class_name ResourceList
extends VBoxContainer

const ROW := preload("res://Scenes/UI/inventory/ResourceRow.tscn")


## Rebuilds the list from `amounts`, in ResourceDB.ALL order.
## `filter` gets (type, amount) and returns true to show that row.
func show_resources(amounts: Dictionary, filter: Callable) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for t in ResourceDB.ALL:
		var amount: int = amounts.get(t.id, 0)
		if not filter.call(t, amount):
			continue
		var row: ResourceRow = ROW.instantiate()
		add_child(row)
		row.setup(t, amount)
