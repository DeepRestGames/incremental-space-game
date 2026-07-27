extends Control

@export var title_label: Label
## Title shown when the expedition ended because the player ran out of oxygen.
@export var asphyxiated_title: String = "ASPHYXIATED"
@export var time_label: Label
@export var destroyed_label: Label
@export var resource_triangle_label: RichTextLabel
@export var resource_circle_label: RichTextLabel
@export var resource_square_label: RichTextLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Only override the title for a specific cause of death; returning to the
	# ship keeps whatever title the scene was authored with.
	if title_label and GameManager.expedition_end_reason == "oxygen":
		title_label.text = asphyxiated_title

	# Display stats
	var total_seconds = GameManager.expedition_time_spent
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	time_label.text = "• Time Spent: %02d:%02d" % [minutes, seconds]
	
	destroyed_label.text = "• Asteroids Destroyed: %d" % GameManager.expedition_destroyed_nodes
	
	_set_resource_text(resource_triangle_label, GameManager.expedition_resources_collected)
	_set_resource_text(resource_circle_label, 0)
	_set_resource_text(resource_square_label, 0)


func _set_resource_text(label: RichTextLabel, amount: int) -> void:
	if GameManager.expedition_success:
		label.text = "x %d" % amount
	else:
		if amount > 0:
			var final_amount = int(amount * 0.2)
			label.text = "x %d [color=#ff5555](-80%%)[/color] = %d" % [amount, final_amount]
		else:
			label.text = "x 0"


func _on_hangar_pressed() -> void:
	GameManager.open_level_select_on_lobby_load = false
	get_tree().change_scene_to_packed(GameManager.lobby_scene)


func _on_again_pressed() -> void:
	EventBus.emit_signal("expedition_started")
