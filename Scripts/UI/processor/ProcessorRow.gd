class_name ProcessorRow
extends HBoxContainer

signal input_clicked(slot_index: int, input_control: Control)
signal input_hovered(slot_index: int, input_control: Control)
signal input_unhovered

const COLOR_DIM := Color(1.0, 1.0, 1.0, 0.4)

var slot_index: int = 0

@onready var _input_slot: ResourceSlot = %InputSlot
@onready var _bar: ProgressBar = %Bar
@onready var _batch_label: Label = %BatchLabel
@onready var _output_slot: ResourceSlot = %OutputSlot


func _ready() -> void:
	_input_slot.gui_input.connect(_on_input_gui_input)
	_output_slot.gui_input.connect(_on_output_gui_input)
	
	_input_slot.mouse_entered.connect(func(): input_hovered.emit(slot_index, _input_slot))
	_input_slot.mouse_exited.connect(func(): input_unhovered.emit())


func _process(_delta: float) -> void:
	var slot: ProcessorManager.Slot = ProcessorManager.slots[slot_index]
	_bar.value = slot.progress

func refresh() -> void:
	var slot: ProcessorManager.Slot = ProcessorManager.slots[slot_index]

	# --- Input Slot ---
	if slot.recipe == null:
		# Empty: glow to invite a click (Step 1)
		_input_slot.clear()
		_input_slot.theme_type_variation = &"SlotGlow"
		_batch_label.hide()
	else:
		var mat: ResourceType = slot.recipe.input_type()
		var owned: int = GameManager.stored_resources.get(mat.id, 0)
		_input_slot.setup(mat, ResourceDB.format_amount(owned))
		var enough: bool = ProcessorManager.has_enough_input(slot_index)
		_input_slot.theme_type_variation = &"SlotPanel" if enough else &"SlotDanger"

		var needed: int = slot.recipe.input_amount()
		_batch_label.visible = needed > 1
		if needed > 1:
			_batch_label.text = "%s =" % ResourceDB.format_amount(needed)

	# --- Output Slot ---
	if slot.pending_output > 0 and slot.output_type != null:
		# Ready to collect: bright + glow (Step 5)
		_output_slot.setup(slot.output_type, ResourceDB.format_amount(slot.pending_output))
		_output_slot.theme_type_variation = &"SlotGlow"
		_output_slot.modulate = Color.WHITE
	elif slot.recipe != null:
		# Result preview while processing (dimmed, Step 4)
		_output_slot.setup(slot.recipe.output, ResourceDB.format_amount(slot.recipe.output_amount))
		_output_slot.theme_type_variation = &"SlotPanel"
		_output_slot.modulate = COLOR_DIM
	else:
		# Completely idle
		_output_slot.clear()
		_output_slot.theme_type_variation = &"SlotPanel"
		_output_slot.modulate = COLOR_DIM



func _on_input_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		input_clicked.emit(slot_index, _input_slot)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		# Step 8: Right-click aborts conversion
		ProcessorManager.clear_slot(slot_index)
		accept_event()


func _on_output_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Step 6: Left-click collects accumulated output
		ProcessorManager.collect(slot_index)
		accept_event()
