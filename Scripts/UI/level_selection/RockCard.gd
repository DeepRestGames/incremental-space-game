class_name RockCard
extends VBoxContainer

## One rock in "Mining Nodes": its square with the spawn chance, and under it
## one line per thing it drops.

@onready var _slot: ResourceSlot = %Slot
@onready var _drops: VBoxContainer = %Drops


func setup(rock: Dictionary) -> void:
	_slot.show_texture(rock["texture"], "%d%%" % rock["pct"])
	for d in rock["drops"]:
		var row := HBoxContainer.new()
		var icon := TextureRect.new()
		icon.texture = d["icon"]
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var label := Label.new()
		label.text = d["text"]
		row.add_child(icon)
		row.add_child(label)
		_drops.add_child(row)
