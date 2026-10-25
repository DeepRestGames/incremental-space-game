extends Label

## Prompts for every interactable area the player currently stands in, in entry
## order. Overlapping areas are handled by letting the most recent one win, and by
## only removing the prompt that actually left.
var _active: Array[String] = []


func _ready() -> void:
	const start_expedition_text: String = "Start expedition"
	EventBus.player_enter_expedition_ship_area.connect(_push.bind(start_expedition_text))
	EventBus.player_exit_expedition_ship_area.connect(_pop.bind(start_expedition_text))

	const end_expedition_text: String = "End expedition"
	EventBus.player_enter_expedition_return_area.connect(_push.bind(end_expedition_text))
	EventBus.player_exit_expedition_return_area.connect(_pop.bind(end_expedition_text))

	const skilltree_text: String = "Access Skill Tree"
	EventBus.player_enter_skill_terminal_area.connect(_push.bind(skilltree_text))
	EventBus.player_exit_skill_terminal_area.connect(_pop.bind(skilltree_text))

	const processor_text: String = "Open Processor"
	EventBus.player_enter_shop_area.connect(_push.bind(processor_text))
	EventBus.player_exit_shop_area.connect(_pop.bind(processor_text))

	EventBus.ui_state_changed.connect(_refresh)

	_refresh()


func _push(prompt: String) -> void:
	if not _active.has(prompt):
		_active.append(prompt)
	_refresh()


func _pop(prompt: String) -> void:
	_active.erase(prompt)
	_refresh()


## Single place that decides whether a prompt is on screen and what it says.
func _refresh() -> void:
	if _active.is_empty() or GameManager.is_world_obscured():
		hide()
		return
	text = _active.back()
	show()
