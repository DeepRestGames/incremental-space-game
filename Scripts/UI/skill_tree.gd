@tool
extends Control

@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_name: Label = $DetailPanel/VBoxContainer/SkillName
@onready var detail_points: Label = $DetailPanel/VBoxContainer/SkillPoints
@onready var detail_desc: Label = $DetailPanel/VBoxContainer/SkillDesc

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	clear_skill_info()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for child in get_children():
		if "parent_node" in child and child.parent_node != null:
			var start_pos = child.position + child.size / 2.0
			var end_pos = child.parent_node.position + child.parent_node.size / 2.0
			
			var current_pts = 0
			var parent_pts = 0
			if not Engine.is_editor_hint():
				current_pts = GameManager.get_skill_points(child.skill_id)
				parent_pts = GameManager.get_skill_points(child.parent_node.skill_id)
			
			var line_color = Color(0.45, 0.45, 0.45, 1.0) # Brighter grey for visibility
			if current_pts > 0 and parent_pts > 0:
				line_color = Color(0.2, 0.9, 0.2, 1.0) # Active green line
				
			var line_width = child.width if "width" in child else 6
			draw_line(start_pos, end_pos, line_color, line_width, true)


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
	if Engine.is_editor_hint():
		return
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
	if Engine.is_editor_hint():
		return
	if detail_panel:
		detail_panel.hide()
