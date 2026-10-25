extends Node

## Always-on state for the Material Processor rows.
## Lives in an autoload so conversions keep running during expeditions and menus.

## Emitted when a recipe changes, a cycle finishes, a slot runs out, or output is collected.
## Note: NOT emitted every frame for progress bar movement; UI reads `slot.progress` in _process.
signal changed

const MAX_SLOTS: int = 4


class Slot:
	var recipe: ConversionRecipe = null
	var progress: float = 0.0
	## Stored separately from `recipe` so uncollected output still knows its icon
	## and ResourceType even after the input runs out or is aborted (Row 2 / Step 8).
	var output_type: ResourceType = null
	var pending_output: int = 0


var slots: Array[Slot] = []


func _ready() -> void:
	# Keep ticking even when the inventory or processor UI pauses the SceneTree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in MAX_SLOTS:
		slots.append(Slot.new())


func _process(delta: float) -> void:
	var unlocked: int = mini(SkillModifiers.get_processor_slots(), MAX_SLOTS)
	for i in unlocked:
		_tick_slot(slots[i], delta)


func _tick_slot(slot: Slot, delta: float) -> void:
	if slot.recipe == null:
		return

	var mat: ResourceType = slot.recipe.input_type()
	var needed: int = slot.recipe.input_amount()
	var owned: int = GameManager.stored_resources.get(mat.id, 0) if mat else 0

	# 0 left in storage -> clear the input slot completely.
	if owned <= 0 or needed <= 0:
		slot.recipe = null
		slot.progress = 0.0
		changed.emit()
		return

	# Have some, but less than a batch (e.g. 5/6) -> keep recipe for red outline, halt bar.
	if owned < needed:
		if slot.progress != 0.0:
			slot.progress = 0.0
			changed.emit()
		return

	var cycle_time: float = slot.recipe.duration / maxf(SkillModifiers.get_processor_speed(), 0.01)
	slot.progress += delta / maxf(cycle_time, 0.01)

	if slot.progress >= 1.0:
		slot.progress -= 1.0
		if GameManager.spend({mat: needed}):
			slot.output_type = slot.recipe.output
			slot.pending_output += slot.recipe.output_amount

			var remaining: int = GameManager.stored_resources.get(mat.id, 0)
			if remaining <= 0:
				slot.recipe = null
				slot.progress = 0.0
			elif remaining < needed:
				slot.progress = 0.0
		changed.emit()


func set_recipe(slot_idx: int, recipe: ConversionRecipe) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return
	if recipe == null:
		clear_slot(slot_idx)
		return
	var slot: Slot = slots[slot_idx]
	# If switching to a recipe with a different output, auto-collect what's waiting first.
	if slot.pending_output > 0 and slot.output_type != recipe.output:
		collect(slot_idx)
	slot.recipe = recipe
	slot.progress = 0.0
	changed.emit()


func clear_slot(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return
	var slot: Slot = slots[slot_idx]
	slot.recipe = null
	slot.progress = 0.0
	changed.emit()


func collect(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx >= slots.size():
		return
	var slot: Slot = slots[slot_idx]
	if slot.pending_output <= 0 or slot.output_type == null:
		return
	GameManager.grant({slot.output_type: slot.pending_output})
	slot.pending_output = 0
	if slot.recipe == null:
		slot.output_type = null
	changed.emit()


## False when a recipe is assigned but stored stock is below the batch requirement (red outline).
func has_enough_input(slot_idx: int) -> bool:
	var slot: Slot = slots[slot_idx]
	if slot.recipe == null:
		return false
	var mat: ResourceType = slot.recipe.input_type()
	return GameManager.stored_resources.get(mat.id, 0) >= slot.recipe.input_amount()
	


## True while at least one unlocked row is actually converting (its bar is moving).
func is_working() -> bool:
	var unlocked: int = mini(SkillModifiers.get_processor_slots(), MAX_SLOTS)
	for i in unlocked:
		if has_enough_input(i):
			return true
	return false
