@tool
extends Control

@export_group("Navigation")
@export var zoom_min: float = 0.4
@export var zoom_max: float = 1.2
## Zoom added or removed per mouse wheel notch.
@export var zoom_step: float = 0.1
## Reset pan and zoom every time the tree is opened. Turn off to keep the last view.
@export var reset_view_on_open: bool = true
## Extra PIXELS past the content edge. 0 = hard stop at the edges.
@export var pan_slack: float = 300.0

## Holds every SkillNode. Panning moves it and zooming scales it, so the detail
## panel and the background stay put.
@onready var tree_view: Control = $TreeView

@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_name: Label = get_node_or_null("DetailPanel/HBoxContainer/VBoxContainer/SkillName")
@onready var detail_points: Label = get_node_or_null("DetailPanel/HBoxContainer/VBoxContainer/SkillPoints")
@onready var detail_desc: Label = get_node_or_null("DetailPanel/HBoxContainer/VBoxContainer/SkillDesc")
@onready var detail_icon: TextureRect = get_node_or_null("DetailPanel/HBoxContainer/DetailIcon")
@onready var detail_stat_value: Label = get_node_or_null("DetailPanel/HBoxContainer/VBoxContainer/SkillStatValue")
@onready var detail_type: Label = get_node_or_null("DetailPanel/HBoxContainer/VBoxContainer/SkillModifierType")

var _dragging: bool = false
var _content_rect: Rect2 = Rect2() # cache for panning edge

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	clear_skill_info()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Node global positions already include the pan and zoom of TreeView, but their
	# size does not, so the centre offset and the line width are scaled by hand.
	var zoom: float = tree_view.scale.x if tree_view else 1.0

	var nodes = get_all_skill_nodes()
	for child in nodes:
		if child.parent_node != null:
			var start_pos = (child.global_position - global_position) + child.size * zoom / 2.0
			var end_pos = (child.parent_node.global_position - global_position) + child.parent_node.size * zoom / 2.0

			var line_color = Color(0.05, 0.95, 0.95, 1.0) # Brighter grey for visibility
			
			if not Engine.is_editor_hint():
				var a_std = get_nearest_standard_ancestor(child)
				var d_stds = get_nearest_standard_descendants(child)
				
				if a_std != null and not d_stds.is_empty():
					var a_pts = GameManager.get_skill_points(a_std.skill_id)
					var has_blue_path = false
					var has_green_path = false
					
					for d_std in d_stds:
						if is_node_fully_upgraded(a_std) and is_node_fully_upgraded(d_std):
							has_blue_path = true
							break
						elif a_pts > 0:
							has_green_path = true
							
					if has_blue_path:
						line_color = Color(0.1, 0.5, 1.0, 1.0) # Active Blue line
					elif has_green_path:
						line_color = Color(0.2, 0.9, 0.2, 1.0) # Active Green line
			
			var line_width = (child.width if "width" in child else 6) * zoom
			draw_line(start_pos, end_pos, line_color, line_width, true)


func get_all_skill_nodes() -> Array[SkillNode]:
	var list: Array[SkillNode] = []
	_gather_skill_nodes_recursive(self, list)
	return list


func _gather_skill_nodes_recursive(node: Node, list: Array[SkillNode]) -> void:
	for child in node.get_children():
		if child is SkillNode:
			list.append(child)
		_gather_skill_nodes_recursive(child, list)


func get_nearest_standard_ancestor(node: SkillNode) -> SkillNode:
	var current = node.parent_node
	while current != null:
		if not current.is_connector:
			return current
		current = current.parent_node
	return null


func get_nearest_standard_descendants(node: SkillNode) -> Array[SkillNode]:
	var result: Array[SkillNode] = []
	_find_standard_descendants_recursive(node, result)
	return result


func _find_standard_descendants_recursive(node: SkillNode, result: Array[SkillNode]) -> void:
	if not node.is_connector:
		result.append(node)
		return
	# If it is a connector, search its children
	var nodes = get_all_skill_nodes()
	for child in nodes:
		if child.parent_node == node:
			_find_standard_descendants_recursive(child, result)


func is_node_fully_upgraded(node: SkillNode) -> bool:
	if Engine.is_editor_hint():
		return false
	if not node or node.skill_id == "":
		return false
	var points = GameManager.get_skill_points(node.skill_id)
	return points >= GameManager.get_skill_max_levels(node.skill_id)


func open() -> void:
	show()
	if get_tree():
		get_tree().paused = true
	GameManager.skill_tree_open = true
	clear_skill_info()
	_cache_content_rect()
	if reset_view_on_open:
		reset_view()
	_clamp_view()

## Puts the tree back to its authored position and scale.
func reset_view() -> void:
	_dragging = false
	tree_view.position = Vector2.ZERO
	tree_view.scale = Vector2.ONE
	_clamp_view()


func close() -> void:
	hide()
	if get_tree():
		get_tree().paused = false
	GameManager.skill_tree_open = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## Pan with left click and drag on empty space, zoom with the mouse wheel.
## Drags that start on a SkillNode are not seen here: the node handles its own
## click first, so buying a skill never turns into a pan.
func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = event.pressed
				accept_event()
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_at(event.position, zoom_step)
				accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at(event.position, -zoom_step)
				accept_event()
	elif event is InputEventMouseMotion and _dragging:
		tree_view.position += event.relative
		_clamp_view()
		accept_event()

## Bounding box of every skill node, in TreeView's local space
func _cache_content_rect() -> void:
	# merge all Control (node) children to get whole BB
	var rect := Rect2()
	var has_any := false
	for child in tree_view.get_children():
		if child is Control:
			var child_rect := Rect2(child.position, child.size)
			rect = rect.merge(child_rect) if has_any else child_rect # altrimenti merge con Rect2 lo riporta a 0,0
			has_any = true
	_content_rect = rect if has_any else Rect2()
	
func _clamp_view() -> void:
	if _content_rect.size == Vector2.ZERO or size == Vector2.ZERO:
		push_warning("skill_tree: _clamp_view() before _cache_content_rect()")
		return

	# Padding the bounds out to the
	# viewport's aspect ratio gives both axes proportional travel instead of locking
	# whichever one has room to spare.
	var aspect: float = size.x / size.y
	var pad_x: float = maxf(0.0, _content_rect.size.y * aspect - _content_rect.size.x) * 0.5
	var pad_y: float = maxf(0.0, _content_rect.size.x / aspect - _content_rect.size.y) * 0.5
	var bounds := _content_rect.grow_individual(pad_x, pad_y, pad_x, pad_y)

	var z: float = tree_view.scale.x
	var pos := tree_view.position
	pos.x = _clamp_axis(pos.x, bounds.position.x, bounds.end.x, size.x, z)
	pos.y = _clamp_axis(pos.y, bounds.position.y, bounds.end.y, size.y, z)
	tree_view.position = pos


## upper`/`lower` are the positions at which the content edge meets the viewport edge; 
func _clamp_axis(value: float, content_start: float, content_end: float, view_size: float, zoom: float) -> float:
	var upper := -content_start * zoom + pan_slack
	var lower := view_size - content_end * zoom - pan_slack
	if lower > upper:
		return (lower + upper) * 0.5
	return clampf(value, lower, upper)
	

## Zooms while keeping whatever sits under `pivot` anchored to the cursor.
func _zoom_at(pivot: Vector2, zoom_delta: float) -> void:
	var old_zoom: float = tree_view.scale.x
	var new_zoom: float = clampf(old_zoom + zoom_delta, zoom_min, zoom_max)
	if is_equal_approx(new_zoom, old_zoom):
		return

	tree_view.position = pivot - (pivot - tree_view.position) * (new_zoom / old_zoom)
	tree_view.scale = Vector2(new_zoom, new_zoom)
	_clamp_view()


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
	var max_pts = GameManager.get_skill_max_levels(skill_id)
	
	if detail_name:
		detail_name.text = s_name
	if detail_points:
		if points < max_pts:
			detail_points.text = "Level: %d / %d   (Cost: %d)" % [points, max_pts, GameManager.get_skill_cost(skill_id)]
		else:
			detail_points.text = "Level: %d / %d" % [points, max_pts]
	if detail_desc:
		detail_desc.text = s_desc
		
	# Find icon dynamically from matching SkillNode child
	var icon_texture: Texture2D = null
	for child in get_all_skill_nodes():
		if child.skill_id == skill_id:
			if child.skill_icon:
				icon_texture = child.skill_icon.texture
			break
			
	if detail_icon:
		detail_icon.texture = icon_texture
		
	# Calculate stat before -> after values and modifier type
	var effects = skill_info.get("effects", {})
	var effect_name = ""
	var effect_data = null
	for key in effects:
		effect_name = key
		effect_data = effects[key]
		break
		
	if effect_data != null:
		var type = "FLAT"
		var val = 0.0
		if effect_data is Dictionary:
			type = effect_data.get("type", "FLAT")
			val = effect_data.get("value", 0.0)
		else:
			val = float(effect_data)
			
		var is_percentage = (type == "ADDITIVE" or type == "MULTIPLICATIVE" or effect_name.contains("chance") or effect_name.contains("ratio") or effect_name.contains("pct") or (type == "FLAT" and val < 1.0))
		
		var current_val = _calculate_effect_value(points, type, val)
		var cur_str = _format_effect_value(current_val, is_percentage)
		
		var stat_value_text = ""
		if points < max_pts:
			var next_val = _calculate_effect_value(points + 1, type, val)
			var next_str = _format_effect_value(next_val, is_percentage)
			stat_value_text = "Effect: %s -> %s" % [cur_str, next_str]
		else:
			stat_value_text = "Effect: %s (Max)" % [cur_str]
			
		if detail_stat_value:
			detail_stat_value.text = stat_value_text
			detail_stat_value.show()
			
		if detail_type:
			detail_type.text = "Modifier Type: %s" % type.capitalize()
			detail_type.show()
	else:
		if detail_stat_value:
			detail_stat_value.hide()
		if detail_type:
			detail_type.hide()
		
	if detail_panel:
		detail_panel.show()


func clear_skill_info() -> void:
	if Engine.is_editor_hint():
		return
	if detail_panel:
		detail_panel.hide()


func _calculate_effect_value(rank: int, type: String, value: float) -> float:
	if rank <= 0:
		return 0.0
	match type:
		"FLAT", "ADDITIVE":
			return rank * value
		"MULTIPLICATIVE":
			return value * pow(1.2, rank - 1)
	return 0.0


func _format_effect_value(val: float, is_pct: bool) -> String:
	if is_pct:
		var pct_val = val * 100.0
		if abs(pct_val - round(pct_val)) < 0.01:
			return "%+d%%" % round(pct_val) if pct_val != 0.0 else "0%"
		else:
			return "%+.1f%%" % pct_val if pct_val != 0.0 else "0%"
	else:
		if abs(val - round(val)) < 0.01:
			return "%+d" % round(val) if val != 0.0 else "0"
		else:
			return "%+.1f" % val if val != 0.0 else "0"
