extends Control

## Level Selection UI Controller
## Displays available level variants, their resource weight percentages, and spawning conditions.

signal level_selected(level_path: String)

# Level data itself lives in LevelDB. Kept here is only what has to be computed
# by instancing each level scene: level id -> {"resources": [...], "conditions": [...]}
var level_ids: Array = LevelDB.get_ids()
var dynamic_data: Dictionary = {}

var current_index: int = 0

@onready var level_name_label: Label = $Panel/CenterContainer/LevelNameLabel
@onready var planet_visual: Panel = $Panel/CenterContainer/PlanetVisual
@onready var resources_label: Label = $Panel/RightSidebar/ResourcesLabel
@onready var conditions_label: Label = $Panel/RightSidebar/ConditionsLabel

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_dynamic_level_data()
	update_ui()
	if GameManager.open_level_select_on_lobby_load:
		GameManager.open_level_select_on_lobby_load = false
		call_deferred("open")


func _load_dynamic_level_data() -> void:
	for level_id in level_ids:
		dynamic_data[level_id] = {"resources": [], "conditions": []}

		var scene_path: String = LevelDB.get_scene_path(level_id)
		var scene_pack = load(scene_path) as PackedScene
		if not scene_pack:
			push_error("LevelSelectUI: Failed to load scene path " + scene_path)
			continue

		var temp_instance = scene_pack.instantiate()
		var gen = temp_instance.get_node_or_null("MapCoordinateGenerator")
		if gen:
			# Calculate percentages
			var dist: Dictionary = gen.spawn_distribution
			var total_w := 0.0
			for sc in dist:
				if sc:
					total_w += dist[sc]
				
			var items_pct: Array[Dictionary] = []
			for sc in dist:
				if not sc:
					continue
				if total_w > 0:
					var pct = (dist[sc] / total_w) * 100.0
					var raw_name = sc.resource_path.get_file().get_basename()
					var name_clean = raw_name.replace("breakable_", "").capitalize() + " Breakable"
					items_pct.append({"name": name_clean, "pct": int(pct)})
			
			# Sort resources to have a consistent UI display
			items_pct.sort_custom(func(a, b): return a["name"] < b["name"])
			dynamic_data[level_id]["resources"] = items_pct
			
			# Build dynamic conditions from Modifiers node or fallback to MapCoordinateGenerator
			var conditions_list: Array[Dictionary] = []
			var modifiers = temp_instance.get_node_or_null("Modifiers")
			if modifiers:
				if "conditions" in modifiers:
					var cond_array = modifiers.conditions
					if cond_array.is_empty():
						conditions_list.append({"label": "", "val": "NONE SET"})
					else:
						for cond in cond_array:
							conditions_list.append({"label": "", "val": cond})
							
			# Fallback if no custom modifiers node is present
			if conditions_list.is_empty() and gen:
				conditions_list.append({"label": "Area Size", "val": "%dx%d" % [gen.map_size.x, gen.map_size.y]})
				conditions_list.append({"label": "Density", "val": "%d - %d" % [gen.min_spawn_count, gen.max_spawn_count]})
				conditions_list.append({"label": "Min Distance", "val": "%d px" % gen.min_distance})
				conditions_list.append({"label": "Safe Area", "val": "%d px" % gen.center_safe_radius})
				conditions_list.append({"label": "Seeds / Spread", "val": "%d / %d px" % [gen.num_seeds, gen.cluster_spread]})
				
			dynamic_data[level_id]["conditions"] = conditions_list

		temp_instance.free()



func open() -> void:
	show()
	GameManager.game_paused = true
	GameManager.level_select_open = true


func close() -> void:
	hide()
	GameManager.game_paused = false
	GameManager.level_select_open = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()



func update_ui() -> void:
	if level_ids.is_empty():
		return

	var level_id: String = level_ids[current_index]
	var extra: Dictionary = dynamic_data.get(level_id, {"resources": [], "conditions": []})

	level_name_label.text = LevelDB.get_level_name(level_id)

	# Modulate the circular visual representing the moon/planet
	planet_visual.self_modulate = LevelDB.get_planet_color(level_id)

	# Format Resources Text
	var res_text := "RESOURCES\n"
	res_text += "-------------------\n"
	for res in extra["resources"]:
		var icon := "⬡" if res["name"] == "Small Breakable" else "⬢"
		res_text += "%s %s: %d%%\n" % [icon, res["name"], res["pct"]]
	resources_label.text = res_text
	
	# Format Conditions Text
	var cond_text := "CONDITIONS\n"
	cond_text += "-------------------\n"
	for cond in extra["conditions"]:
		if cond["label"] == "":
			cond_text += "• %s\n" % cond["val"]
		else:
			cond_text += "• %s: %s\n" % [cond["label"], cond["val"]]
	conditions_label.text = cond_text


func _on_left_button_pressed() -> void:
	current_index = (current_index - 1 + level_ids.size()) % level_ids.size()
	update_ui()


func _on_right_button_pressed() -> void:
	current_index = (current_index + 1) % level_ids.size()
	update_ui()


func _on_select_button_pressed() -> void:
	var level_id: String = level_ids[current_index]
	GameManager.select_level(level_id)
	level_selected.emit(LevelDB.get_scene_path(level_id))
	close()
	EventBus.expedition_started.emit()


func _on_close_button_pressed() -> void:
	close()
