class_name MaterialPicker
extends PanelContainer

signal recipe_hovered(recipe: ConversionRecipe, slot_control: Control)
signal clear_hovered(slot_control: Control)
signal item_unhovered

const SLOT_SCENE := preload("res://Scenes/UI/inventory/ResourceSlot.tscn")
const COLOR_RED := Color(0.933, 0.169, 0.345, 1.0)
const COLOR_DIM := Color(1.0, 1.0, 1.0, 0.4)

@onready var _grid: GridContainer = %Grid

var _target_slot: int = -1
var _anchor: Control = null


func is_open_for(slot_idx: int) -> bool:
	return visible and _target_slot == slot_idx


func open_for(slot_idx: int, anchor: Control) -> void:
	_target_slot = slot_idx
	_anchor = anchor
	_populate()
	show()
	# Force PanelContainer to recalculate its size from the new grid children now,
	# so `size.x` is accurate on this very frame when centering below `anchor`.
	reset_size()
	var rect: Rect2 = anchor.get_global_rect()
	global_position = Vector2(
		rect.get_center().x - size.x * 0.5,
		rect.end.y + 15.0
	)


func close() -> void:
	if visible:
		item_unhovered.emit()
	hide()
	_target_slot = -1
	_anchor = null


func _populate() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()

	for recipe in RecipeDB.recipes_for(&"processor"):
		var mat: ResourceType = recipe.input_type()
		if mat == null:
			continue
		var owned: int = GameManager.stored_resources.get(mat.id, 0)
		var slot: ResourceSlot = SLOT_SCENE.instantiate()
		_grid.add_child(slot)
		slot.setup(mat, ResourceDB.format_amount(owned) if owned > 0 else "")
		if owned < recipe.input_amount():
			slot.modulate = COLOR_DIM
		slot.gui_input.connect(_on_recipe_slot_input.bind(recipe))
		slot.mouse_entered.connect(func(): recipe_hovered.emit(recipe, slot))
		slot.mouse_exited.connect(func(): item_unhovered.emit())

	_add_clear_slot()


func _add_clear_slot() -> void:
	var slot: ResourceSlot = SLOT_SCENE.instantiate()
	_grid.add_child(slot)
	slot.clear()

	slot.theme_type_variation = &"SlotDanger"

	var x_label := Label.new()
	x_label.text = "✕"
	x_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	x_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	x_label.add_theme_color_override("font_color", COLOR_RED)
	x_label.add_theme_font_size_override("font_size", 32)
	slot.add_child(x_label)

	slot.gui_input.connect(_on_clear_slot_input)
	slot.mouse_entered.connect(func(): clear_hovered.emit(slot))
	slot.mouse_exited.connect(func(): item_unhovered.emit())


func _on_recipe_slot_input(event: InputEvent, recipe: ConversionRecipe) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ProcessorManager.set_recipe(_target_slot, recipe)
		close()
		accept_event()


func _on_clear_slot_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ProcessorManager.clear_slot(_target_slot)
		close()
		accept_event()
