extends Control

@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_name: Label = $DetailPanel/VBoxContainer/SkillName
@onready var detail_points: Label = $DetailPanel/VBoxContainer/SkillPoints
@onready var detail_desc: Label = $DetailPanel/VBoxContainer/SkillDesc

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	clear_skill_info()


func open() -> void:
	show()
	if get_tree():
		get_tree().paused = true
	GameManager.skill_tree_open = true
	clear_skill_info()


func close() -> void:
	hide()
	if get_tree():
		get_tree().paused = false
	GameManager.skill_tree_open = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func display_skill_info(skill_id: String) -> void:
	if skill_id == "" or not GameManager.skill_db.has(skill_id):
		clear_skill_info()
		return
		
	var skill_info = GameManager.skill_db[skill_id]
	var s_name = skill_info.get("name", "Unknown Skill")
	var s_desc = skill_info.get("description", "")
	var points = GameManager.get_skill_points(skill_id)
	var max_pts = skill_info.get("max_points", 5)
	
	if detail_name:
		detail_name.text = s_name
	if detail_points:
		detail_points.text = "Level: %d / %d" % [points, max_pts]
	if detail_desc:
		detail_desc.text = s_desc
		
	if detail_panel:
		detail_panel.show()


func clear_skill_info() -> void:
	if detail_panel:
		detail_panel.hide()
