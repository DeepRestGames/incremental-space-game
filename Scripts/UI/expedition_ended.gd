extends Control

@onready var time_label: Label = %TimeLabel
@onready var destroyed_label: Label = %DestroyedLabel
@onready var resource_triangle_label: Label = %ResourceTriangleLabel
@onready var resource_circle_label: Label = %ResourceCircleLabel
@onready var resource_square_label: Label = %ResourceSquareLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Display stats
	var total_seconds = GameManager.expedition_time_spent
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	time_label.text = "• Time Spent: %02d:%02d" % [minutes, seconds]
	
	destroyed_label.text = "• Asteroids Destroyed: %d" % GameManager.expedition_destroyed_nodes
	resource_triangle_label.text = "∇  %d" % GameManager.expedition_resources_collected
	resource_circle_label.text = "◯  0"
	resource_square_label.text = "▢  0"


func _on_hangar_pressed() -> void:
	GameManager.open_level_select_on_lobby_load = false
	get_tree().change_scene_to_packed(GameManager.lobby_scene)


func _on_again_pressed() -> void:
	EventBus.emit_signal("expedition_started")
