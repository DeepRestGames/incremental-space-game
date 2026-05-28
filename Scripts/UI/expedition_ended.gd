extends Control

@export var time_label: Label
@export var destroyed_label: Label
@export var resource_triangle_label: Label
@export var resource_circle_label: Label
@export var resource_square_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Display stats
	var total_seconds = GameManager.expedition_time_spent
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	time_label.text = "• Time Spent: %02d:%02d" % [minutes, seconds]
	
	destroyed_label.text = "• Asteroids Destroyed: %d" % GameManager.expedition_destroyed_nodes
	resource_triangle_label.text = "x %d" % GameManager.expedition_resources_collected
	resource_circle_label.text = "x 0"
	resource_square_label.text = "x 0"


func _on_hangar_pressed() -> void:
	GameManager.open_level_select_on_lobby_load = false
	get_tree().change_scene_to_packed(GameManager.lobby_scene)


func _on_again_pressed() -> void:
	EventBus.emit_signal("expedition_started")
