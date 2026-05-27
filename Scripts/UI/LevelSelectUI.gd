extends Control

## Level Selection UI Controller
## Displays available level variants, their resource weight percentages, and spawning conditions.

signal level_selected(level_path: String)

# Level database representing all available sectors/worlds
var levels: Array[Dictionary] = [
	{
		"name": "MOON 1234",
		"scene_path": "res://Scenes/Levels/Moon1234.tscn",
		"planet_color": Color(0.65, 0.68, 0.72), # Dusty grey celestial body
		"resources": [
			{"name": "Small Breakable", "pct": 80},
			{"name": "Big Breakable", "pct": 20}
		],
		"conditions": [
			{"label": "Spawning Area", "val": "6000x6000px"},
			{"label": "Safe Spacing", "val": "100px"},
			{"label": "Clump Radius", "val": "320px"},
			{"label": "Safe Spawn", "val": "1200px (Player)"}
		]
	},
	{
		"name": "NEBULA ALPHA",
		"scene_path": "res://Scenes/Levels/Moon1234.tscn", # Reuses scene for now as Moon is our only dynamic scene
		"planet_color": Color(0.9, 0.25, 0.6), # Neon pink/violet theme
		"resources": [
			{"name": "Small Breakable", "pct": 60},
			{"name": "Big Breakable", "pct": 40}
		],
		"conditions": [
			{"label": "Spawning Area", "val": "6000x6000px"},
			{"label": "Safe Spacing", "val": "100px"},
			{"label": "Clump Radius", "val": "320px"},
			{"label": "Safe Spawn", "val": "1200px (Player)"}
		]
	}
]

var current_index: int = 0

@onready var level_name_label: Label = $Panel/CenterContainer/LevelNameLabel
@onready var planet_visual: Panel = $Panel/CenterContainer/PlanetVisual
@onready var resources_label: Label = $Panel/RightSidebar/ResourcesLabel
@onready var conditions_label: Label = $Panel/RightSidebar/ConditionsLabel

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_ui()


func open() -> void:
	show()
	get_tree().paused = true # Pause game elements under UI


func close() -> void:
	hide()
	get_tree().paused = false


func update_ui() -> void:
	if levels.is_empty():
		return
		
	var lvl := levels[current_index]
	level_name_label.text = lvl["name"]
	
	# Modulate the circular visual representing the moon/planet
	planet_visual.self_modulate = lvl["planet_color"]
	
	# Format Resources Text
	var res_text := "RESOURCES\n"
	res_text += "-------------------\n"
	for res in lvl["resources"]:
		var icon := "⬡" if res["name"] == "Small Breakable" else "⬢"
		res_text += "%s %s: %d%%\n" % [icon, res["name"], res["pct"]]
	resources_label.text = res_text
	
	# Format Conditions Text
	var cond_text := "CONDITIONS\n"
	cond_text += "-------------------\n"
	for cond in lvl["conditions"]:
		cond_text += "• %s: %s\n" % [cond["label"], cond["val"]]
	conditions_label.text = cond_text


func _on_left_button_pressed() -> void:
	current_index = (current_index - 1 + levels.size()) % levels.size()
	update_ui()


func _on_right_button_pressed() -> void:
	current_index = (current_index + 1) % levels.size()
	update_ui()


func _on_select_button_pressed() -> void:
	var selected_path: String = levels[current_index]["scene_path"]
	GameManager.selected_level_path = selected_path
	emit_signal("level_selected", selected_path)
	close()
	EventBus.emit_signal("expedition_started")


func _on_close_button_pressed() -> void:
	close()
