class_name ProcessorPanel
extends Control

const ROW_SCENE := preload("res://Scenes/UI/processor/ProcessorRow.tscn")

@onready var _rows_box: VBoxContainer = %Rows
@onready var _picker: MaterialPicker = %MaterialPicker
@onready var _tooltip: ProcessorTooltip = %ProcessorTooltip
var _rows: Array[ProcessorRow] = []


func _ready() -> void:
	hide()
	for i in ProcessorManager.MAX_SLOTS:
		var row: ProcessorRow = ROW_SCENE.instantiate()
		row.slot_index = i
		row.input_clicked.connect(_on_row_input_clicked)
		row.input_hovered.connect(_on_row_input_hovered)
		row.input_unhovered.connect(_tooltip.hide)
		
		_rows_box.add_child(row)
		_rows.append(row)

	_picker.recipe_hovered.connect(func(r: ConversionRecipe, c: Control): _tooltip.show_recipe(c, r))
	_picker.clear_hovered.connect(_tooltip.show_text.bind("Clear slot.\n(Aborts conversion)"))
	_picker.item_unhovered.connect(_tooltip.hide)
	
		
	ProcessorManager.changed.connect(refresh)
	EventBus.update_HUD.connect(refresh)
	EventBus.stats_changed.connect(refresh)


func open() -> void:
	show()
	GameManager.game_paused = true
	GameManager.processor_open = true
	refresh()


func close() -> void:
	_picker.close()
	_tooltip.hide()
	hide()
	GameManager.game_paused = false
	GameManager.processor_open = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _picker.visible:
			_picker.close()
		else:
			close()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if _picker.visible and event is InputEventMouseButton and event.pressed:
		_picker.close()
		accept_event()


func refresh() -> void:
	if not visible:
		return
	var unlocked: int = mini(SkillModifiers.get_processor_slots(), ProcessorManager.MAX_SLOTS)
	for i in _rows.size():
		_rows[i].visible = i < unlocked
		if _rows[i].visible:
			_rows[i].refresh()


func _on_row_input_clicked(slot_idx: int, control: Control) -> void:
	_tooltip.hide()
	if _picker.is_open_for(slot_idx):
		_picker.close()
	else:
		_picker.open_for(slot_idx, control)

func _on_row_input_hovered(slot_idx: int, control: Control) -> void:
	if _picker.visible:
		return
	if ProcessorManager.slots[slot_idx].recipe == null:
		_tooltip.show_text(control, "Add a material to\nan empty slot")
