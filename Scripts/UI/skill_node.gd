@tool
@icon ("res://Addons/at-icons/control/triangle.svg")
class_name SkillNode
extends Control

@export var skill_id: String = ""
@export var parent_node: SkillNode
var width: int = 6

@onready var background: TextureRect = $Background
@onready var skill_icon: TextureRect = $SkillIcon

func _ready() -> void:
	# Add to SkillNodes group to allow dependency traversal
	add_to_group("SkillNodes")
	
	# Enforce mouse filters so parent receives hover/input and tooltips work
	mouse_filter = Control.MOUSE_FILTER_STOP
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if skill_icon:
		skill_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	# Connect hover signals
	if not Engine.is_editor_hint():
		if not mouse_entered.is_connected(_on_mouse_entered):
			mouse_entered.connect(_on_mouse_entered)
		if not mouse_exited.is_connected(_on_mouse_exited):
			mouse_exited.connect(_on_mouse_exited)
	
	update_appearance()
	update_tooltip()


func _on_mouse_entered() -> void:
	var skill_tree = get_parent()
	if skill_tree and skill_tree.has_method("display_skill_info"):
		skill_tree.display_skill_info(skill_id)


func _on_mouse_exited() -> void:
	var skill_tree = get_parent()
	if skill_tree and skill_tree.has_method("clear_skill_info"):
		skill_tree.clear_skill_info()



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			add_point()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			remove_point()


func can_add_point() -> bool:
	if parent_node != null:
		# Can only add points if parent has at least 1 point
		if Engine.is_editor_hint():
			return false
		return GameManager.get_skill_points(parent_node.skill_id) > 0
	return true


func can_remove_point() -> bool:
	var current_pts = GameManager.get_skill_points(skill_id)
	# If removing the last point (going to 0), ensure no child node is active
	if current_pts == 1:
		var all_nodes = get_tree().get_nodes_in_group("SkillNodes")
		for node in all_nodes:
			if node != self and node.parent_node == self:
				if GameManager.get_skill_points(node.skill_id) > 0:
					return false
	return true


func add_point() -> void:
	if skill_id == "":
		return
		
	var skill_info = GameManager.skill_db.get(skill_id, {})
	var max_points = skill_info.get("max_points", 5)
	var current_points = GameManager.get_skill_points(skill_id)
	
	if current_points < max_points and can_add_point():
		GameManager.set_skill_points(skill_id, current_points + 1)
		
		# Update all nodes in tree to refresh line drawings and lock states
		var all_nodes = get_tree().get_nodes_in_group("SkillNodes")
		for node in all_nodes:
			node.update_appearance()
			node.update_tooltip()
			
		# Refresh the parent tree drawing and hover detail panel in real time
		var skill_tree = get_parent()
		if skill_tree:
			skill_tree.queue_redraw()
			if skill_tree.has_method("display_skill_info"):
				skill_tree.display_skill_info(skill_id)


func remove_point() -> void:
	if skill_id == "":
		return
		
	var current_points = GameManager.get_skill_points(skill_id)
	if current_points > 0 and can_remove_point():
		GameManager.set_skill_points(skill_id, current_points - 1)
		
		# Update all nodes in tree to refresh line drawings and lock states
		var all_nodes = get_tree().get_nodes_in_group("SkillNodes")
		for node in all_nodes:
			node.update_appearance()
			node.update_tooltip()
			
		# Refresh the parent tree drawing and hover detail panel in real time
		var skill_tree = get_parent()
		if skill_tree:
			skill_tree.queue_redraw()
			if skill_tree.has_method("display_skill_info"):
				skill_tree.display_skill_info(skill_id)


func update_appearance() -> void:
	if not is_inside_tree():
		return
		
	if not background or not skill_icon:
		return
		
	if skill_id == "":
		background.modulate = Color(0.4, 0.4, 0.4, 1.0)
		skill_icon.modulate = Color(0.3, 0.3, 0.3, 1.0)
		return
		
	var max_points = 5
	var current_points = 0
	if not Engine.is_editor_hint():
		var skill_info = GameManager.skill_db.get(skill_id, {})
		max_points = skill_info.get("max_points", 5)
		current_points = GameManager.get_skill_points(skill_id)
	
	if current_points > 0:
		# Active (Blue, scaling from a soft sky blue to a very strong, vibrant electric blue based on points ratio)
		var ratio = float(current_points) / float(max_points)
		var bg_color = Color(0.6 * (1.0 - ratio), 0.8 - 0.45 * ratio, 1.0, 1.0)
		var icon_color = Color(0.5 * (1.0 - ratio), 0.7 - 0.3 * ratio, 1.0, 1.0)
		background.modulate = bg_color
		skill_icon.modulate = icon_color
	else:
		# 0 points: check if reachable or locked
		if can_add_point():
			# Unlocked / Reachable (Green)
			background.modulate = Color(0.2, 0.9, 0.2, 1.0)
			skill_icon.modulate = Color(0.15, 0.6, 0.15, 1.0)
		else:
			# Unreachable / Locked (Grey)
			background.modulate = Color(0.35, 0.35, 0.35, 1.0)
			skill_icon.modulate = Color(0.25, 0.25, 0.25, 1.0)


func update_tooltip() -> void:
	if Engine.is_editor_hint():
		return
	if skill_id == "":
		tooltip_text = "Unassigned Skill Node"
		return
		
	var skill_info = GameManager.skill_db.get(skill_id, {})
	var s_name = skill_info.get("name", "Unknown Skill")
	var s_desc = skill_info.get("description", "")
	var points = GameManager.get_skill_points(skill_id)
	var max_pts = skill_info.get("max_points", 5)
	
	# Check lock status for display
	var lock_status = ""
	if parent_node != null and GameManager.get_skill_points(parent_node.skill_id) == 0:
		var parent_name = GameManager.skill_db.get(parent_node.skill_id, {}).get("name", "Parent Skill")
		lock_status = "\n[LOCKED - Requires 1 point in %s]" % parent_name
		
	tooltip_text = "%s%s\n%s\nPoints: %d/%d" % [s_name, lock_status, s_desc, points, max_pts]
