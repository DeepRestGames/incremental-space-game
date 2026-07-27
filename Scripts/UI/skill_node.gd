@tool
@icon ("res://Addons/at-icons/control/triangle.svg")
class_name SkillNode
extends Control

@export var skill_id: String = ""
## Icon shown inside this node. Leave empty to keep the default icon from the
## SkillNode scene. Updates live in the editor.
@export var icon: Texture2D:
	set(value):
		icon = value
		_apply_icon()
@export var parent_node: SkillNode
@export var is_connector: bool = false
var width: int = 6

@onready var background: TextureRect = $Background
@onready var skill_icon: TextureRect = $SkillIcon
@onready var too_expensive_overlay: Panel = $TooExpensiveOverlay

func _ready() -> void:
	# Add to SkillNodes group to allow dependency traversal
	add_to_group("SkillNodes")
	
	if is_connector:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if background:
			background.mouse_filter = Control.MOUSE_FILTER_IGNORE
			background.visible = Engine.is_editor_hint()
		if skill_icon:
			skill_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			skill_icon.visible = false
		if Engine.is_editor_hint():
			modulate.a = 0.4
	else:
		# Enforce mouse filters so parent receives hover/input and tooltips work
		mouse_filter = Control.MOUSE_FILTER_STOP
		if background:
			background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if skill_icon:
			skill_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
	# Connect hover signals
	if not Engine.is_editor_hint() and not is_connector:
		if not mouse_entered.is_connected(_on_mouse_entered):
			mouse_entered.connect(_on_mouse_entered)
		if not mouse_exited.is_connected(_on_mouse_exited):
			mouse_exited.connect(_on_mouse_exited)

		# Refresh the affordability outline whenever money changes
		EventBus.connect("update_HUD", update_appearance)
	
	_apply_icon()
	update_appearance()
	update_tooltip()


## Pushes the exported icon onto the child TextureRect. Safe to call before the
## node is ready (it re-applies in _ready).
func _apply_icon() -> void:
	var icon_rect: TextureRect = skill_icon if skill_icon else get_node_or_null("SkillIcon")
	if icon_rect and icon:
		icon_rect.texture = icon


func _on_mouse_entered() -> void:
	if is_connector:
		return
	var skill_tree = get_skill_tree()
	if skill_tree and skill_tree.has_method("display_skill_info"):
		skill_tree.display_skill_info(skill_id)


func _on_mouse_exited() -> void:
	if is_connector:
		return
	var skill_tree = get_skill_tree()
	if skill_tree and skill_tree.has_method("clear_skill_info"):
		skill_tree.clear_skill_info()


func _gui_input(event: InputEvent) -> void:
	if is_connector:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			add_point()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			remove_point()


func get_skill_tree() -> Node:
	var current = get_parent()
	while current != null:
		if current.has_method("get_all_skill_nodes"):
			return current
		current = current.get_parent()
	return null


func get_nearest_standard_ancestor() -> SkillNode:
	var current = parent_node
	while current != null:
		if not current.is_connector:
			return current
		current = current.parent_node
	return null


func get_child_standard_descendants() -> Array[SkillNode]:
	var result: Array[SkillNode] = []
	var tree = get_skill_tree()
	if not tree:
		return result
	for child in tree.get_all_skill_nodes():
		if child is SkillNode and child.parent_node == self:
			if tree.has_method("get_nearest_standard_descendants"):
				result.append_array(tree.get_nearest_standard_descendants(child))
	return result


func can_add_point() -> bool:
	if is_connector:
		return false
	var ancestor = get_nearest_standard_ancestor()
	if ancestor != null:
		# Can only add points if standard ancestor has at least 1 point
		if Engine.is_editor_hint():
			return false
		return GameManager.get_skill_points(ancestor.skill_id) > 0
	return true


func can_remove_point() -> bool:
	if is_connector:
		return false
	var current_pts = GameManager.get_skill_points(skill_id)
	# If removing the last point (going to 0), ensure no standard descendant of child paths is active
	if current_pts == 1:
		var descendants = get_child_standard_descendants()
		for desc in descendants:
			if GameManager.get_skill_points(desc.skill_id) > 0:
				return false
	return true


func add_point() -> void:
	if is_connector or skill_id == "":
		return
		
	var max_points = GameManager.get_skill_max_levels(skill_id)
	var current_points = GameManager.get_skill_points(skill_id)

	if current_points < max_points and can_add_point():
		var cost := GameManager.get_skill_cost(skill_id)
		if not GameManager.can_afford(cost):
			return
		GameManager.spend_money(cost)
		GameManager.set_skill_points(skill_id, current_points + 1)
		
		# Update all nodes in tree to refresh line drawings and lock states
		var all_nodes = get_tree().get_nodes_in_group("SkillNodes")
		for node in all_nodes:
			node.update_appearance()
			node.update_tooltip()
			
		# Refresh the parent tree drawing and hover detail panel in real time
		var skill_tree = get_skill_tree()
		if skill_tree:
			skill_tree.queue_redraw()
			if skill_tree.has_method("display_skill_info"):
				skill_tree.display_skill_info(skill_id)


func remove_point() -> void:
	if is_connector or skill_id == "":
		return
		
	var current_points = GameManager.get_skill_points(skill_id)
	if current_points > 0 and can_remove_point():
		GameManager.set_skill_points(skill_id, current_points - 1)
		GameManager.add_money(GameManager.get_skill_cost(skill_id))
		
		# Update all nodes in tree to refresh line drawings and lock states
		var all_nodes = get_tree().get_nodes_in_group("SkillNodes")
		for node in all_nodes:
			node.update_appearance()
			node.update_tooltip()
			
		# Refresh the parent tree drawing and hover detail panel in real time
		var skill_tree = get_skill_tree()
		if skill_tree:
			skill_tree.queue_redraw()
			if skill_tree.has_method("display_skill_info"):
				skill_tree.display_skill_info(skill_id)


## True when this skill is unlocked and not maxed, but the player cannot
## currently afford it. Drives the red "too expensive" outline.
func _is_too_expensive() -> bool:
	if Engine.is_editor_hint() or is_connector or skill_id == "":
		return false

	if GameManager.get_skill_points(skill_id) >= GameManager.get_skill_max_levels(skill_id):
		return false
	if not can_add_point():
		return false

	return not GameManager.can_afford(GameManager.get_skill_cost(skill_id))


func update_appearance() -> void:
	if not is_inside_tree():
		return
		
	if not background or not skill_icon:
		return

	if too_expensive_overlay:
		too_expensive_overlay.visible = _is_too_expensive()

	if is_connector:
		background.visible = Engine.is_editor_hint()
		skill_icon.visible = false
		if Engine.is_editor_hint():
			modulate.a = 0.4
			background.modulate = Color(0.6, 0.6, 0.6, 1.0)
		return
		
	if skill_id == "":
		background.modulate = Color(0.4, 0.4, 0.4, 1.0)
		skill_icon.modulate = Color(0.3, 0.3, 0.3, 1.0)
		return
		
	var max_points = 5
	var current_points = 0
	if not Engine.is_editor_hint():
		max_points = GameManager.get_skill_max_levels(skill_id)
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
	if is_connector:
		tooltip_text = ""
		return
	if skill_id == "":
		tooltip_text = "Unassigned Skill Node"
		return
		
	var skill_info = GameManager.skill_db.get(skill_id, {})
	var s_name = skill_info.get("name", "Unknown Skill")
	var s_desc = skill_info.get("description", "")
	var points = GameManager.get_skill_points(skill_id)
	var max_pts = GameManager.get_skill_max_levels(skill_id)

	# Check lock status for display
	var lock_status = ""
	var ancestor = get_nearest_standard_ancestor()
	if ancestor != null and GameManager.get_skill_points(ancestor.skill_id) == 0:
		var ancestor_name = GameManager.skill_db.get(ancestor.skill_id, {}).get("name", "Parent Skill")
		lock_status = "\n[LOCKED - Requires 1 point in %s]" % ancestor_name
		
	var cost_line := ""
	if points < max_pts:
		cost_line = "\nCost: %d" % GameManager.get_skill_cost(skill_id)
	tooltip_text = "%s%s\n%s\nPoints: %d/%d%s" % [s_name, lock_status, s_desc, points, max_pts, cost_line]
