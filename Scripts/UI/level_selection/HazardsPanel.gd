class_name HazardsPanel
extends PanelContainer

## The red panel: what's dangerous about a planet. Hidden when nothing is.

## Shown next to hazards worked out from numbers, e.g. faster oxygen drain.
@export var oxygen_icon: Texture2D


func show_level(level: LevelData) -> void:
	for child in %Rows.get_children():
		%Rows.remove_child(child)
		child.queue_free()
	var info := LevelPreview.read(level)
	# Worked out from the planet's own number, so the text can't drift from it.
	var oxy: float = info["oxygen_multiplier"]
	if oxy > 1.0:
		_add_row(oxygen_icon, "Oxygen drains x%.1f" % oxy)
	for c in info["conditions"]:
		_add_row(c.icon, c.title)
	visible = %Rows.get_child_count() > 0


func _add_row(icon: Texture2D, text: String) -> void:
	var row := HBoxContainer.new()
	var tex := TextureRect.new()
	tex.texture = icon
	tex.custom_minimum_size = Vector2(32, 32)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var label := Label.new()
	label.text = text
	row.add_child(tex)
	row.add_child(label)
	%Rows.add_child(row)
