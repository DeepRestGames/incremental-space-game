class_name LevelSelectScreen
extends Control

## The planet picker. Planets are PlanetButtons placed by hand inside %Planets;
## this script only wires them together.

signal planet_selected(level: LevelData)

var selected_level: LevelData

var _group := ButtonGroup.new()


func _ready() -> void:
	hide()
	# Opening pauses the game, so the screen itself must keep running.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# The ship finds the screen by group, not by path: move it around the
	# Lobby freely without breaking anything.
	add_to_group("level_select")
	for b in _planet_buttons():
		b.button_group = _group
		# Mouse click and arrow keys both end up here: either way the
		# button gets the focus, and the focused planet is the selected one.
		b.focus_entered.connect(_select.bind(b))
	planet_selected.connect(%NodesPanel.show_level)
	planet_selected.connect(%HazardsPanel.show_level)
	EventBus.stats_changed.connect(_on_stats_changed)
	# Run on its own (F6): open straight away, for testing.
	if get_parent() == get_tree().root:
		open()


func open() -> void:
	show()
	GameManager.game_paused = true
	GameManager.level_select_open = true
	var current := _button_for(GameManager.selected_level_id)
	if current == null:
		for b in _planet_buttons():
			if not b.disabled:
				current = b
				break
	if current:
		current.grab_focus.call_deferred()


func close() -> void:
	hide()
	GameManager.game_paused = false
	GameManager.level_select_open = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	if selected_level == null or not selected_level.is_playable():
		return
	GameManager.select_level(selected_level.id)
	close()
	EventBus.expedition_started.emit()

func _select(b: PlanetButton) -> void:
	b.button_pressed = true
	selected_level = b.level
	planet_selected.emit(b.level)


func _planet_buttons() -> Array[PlanetButton]:
	var out: Array[PlanetButton] = []
	for n in %Planets.get_children():
		if n is PlanetButton:
			out.append(n)
	return out


func _button_for(level_id: StringName) -> PlanetButton:
	for b in _planet_buttons():
		if b.level and b.level.id == level_id and not b.disabled:
			return b
	return null
	

## A skill can change a planet's numbers: forget what was read, and redraw.
func _on_stats_changed() -> void:
	LevelPreview.clear_cache()
	if selected_level:
		planet_selected.emit(selected_level)
