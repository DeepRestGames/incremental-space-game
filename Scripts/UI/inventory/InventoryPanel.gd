extends CanvasLayer

@onready var _panel: Control = $Panel
@onready var _title: Label = %Title
@onready var _capacity: Label = %Capacity
@onready var _list: ResourceList = %List

## True only if this panel paused the game.
var _paused_by_me := false
## Opened on top of the skill tree
var _over_skill_tree := false

func _ready() -> void:
	_panel.hide()
	EventBus.update_HUD.connect(_refresh)
	EventBus.ui_state_changed.connect(_refresh)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if _panel.visible:
			_close()
		elif _can_open():
			_open()
		else:
			# praticamente tab viene usato di default per spostare il focus dei bottoni 
			# e mettere return qua gli permette di farlo lo stesso 
			# (+ il non mettere unhandled_input invece di _input)
			return  
		get_viewport().set_input_as_handled()
	elif _panel.visible and event.is_action_pressed("ui_cancel"):
		# Così ESC lo chiude invece di andare in pausa sopra all'inventario
		_close()
		get_viewport().set_input_as_handled()


func _can_open() -> bool:
	if GameManager.transitioning or GameManager.is_expedition_starting():
		return false
	# On top of the skill tree is fine
	return GameManager.skill_tree_open or not (GameManager.game_paused or GameManager.is_modal_ui_open())


func _open() -> void:
	_over_skill_tree = GameManager.skill_tree_open
	if not GameManager.game_paused:
		GameManager.game_paused = true
		_paused_by_me = true
	_panel.show()
	GameManager.inventory_open = true
	_refresh()


func _close() -> void:
	_panel.hide()
	GameManager.inventory_open = false
	if _paused_by_me:
		_paused_by_me = false
		GameManager.game_paused = false


func _refresh() -> void:
	# Guardie: something went wrong
	if not _panel.visible:
		return
	if _over_skill_tree and not GameManager.skill_tree_open:
		_close()
		return

	if GameManager.skill_tree_open:
		_title.text = "Resources (spendable only)"
		_capacity.hide()
		_list.show_resources(GameManager.stored_resources, _spendable)
	elif GameManager.expedition_started:
		_title.text = "Resources (bag)"
		_capacity.text = "%d / %d" % [GameManager.carried_total(), GameManager.get_max_player_resource()]
		_capacity.show()
		_list.show_resources(GameManager.expedition_player_resources, _held)
	else:
		_title.text = "Resources (stored)"
		_capacity.hide()
		_list.show_resources(GameManager.stored_resources, _discovered)


# --- filters: (type, amount) -> show this row? ---

func _discovered(t: ResourceType, _amount: int) -> bool:
	return GameManager.is_discovered(t.id)


func _held(_t: ResourceType, amount: int) -> bool:
	return amount > 0


func _spendable(t: ResourceType, _amount: int) -> bool:
	return GameManager.is_discovered(t.id) and SkillDB.uses_resource(t.id)
