extends Control

#Death warning panel - only shown when you die
@export var death_label: Label
@export var death_warning_panel: PanelContainer
@export var death_tip_label: Label
@export var death_effect: Label
## Title shown when the expedition ended because the player ran out of oxygen.
@export var asphyxiated_title: String = "ASPHYXIATED"
@export var asphyxiated_tip: String = "Get back to your ship before you run out of oxygen!"
@export var time_label: Label
@export var destroyed_label: Label
@export var depth_label: Label
@export var resource_list: ResourceList
@export var loss_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Only override the title for a specific cause of death; returning to the
	# ship keeps whatever title the scene was authored with.
	if death_label and GameManager.expedition_end_reason == "oxygen":
		death_label.text = asphyxiated_title
	if death_tip_label and GameManager.expedition_end_reason == "oxygen":
		death_tip_label.text = asphyxiated_tip
		
	
	# Display stats
	var total_seconds = GameManager.expedition_time_spent
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	time_label.text = "Time Spent: %02d:%02d" % [minutes, seconds]
	
	destroyed_label.text = "Nodes Mined: %d" % GameManager.expedition_destroyed_nodes
	
	depth_label.visible = GameManager.current_depth > 0
	if depth_label.visible:
		depth_label.text = "Max Depth: %d" % GameManager.current_depth

	resource_list.show_resources(GameManager.expedition_resources_collected, _gathered, _amount_text)

	death_warning_panel.visible = not GameManager.expedition_success
	if death_warning_panel.visible:
		var kept_pct := roundi(SkillModifiers.get_failure_keep_ratio() * 100)
		death_effect.text = "Lost %d%% of your cargo" % (100-kept_pct)


func _gathered(_t: ResourceType, amount: int) -> bool:
	return amount > 0


func _amount_text(t: ResourceType, collected: int) -> String:
	if GameManager.expedition_success:
		return str(collected)
	return str(GameManager.expedition_resources_kept.get(t.id, 0))


func _on_hangar_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.lobby_scene)
# TODO: make a transition with:
# TransitionManager.change_scene(get_selected_level_path())


func _on_again_pressed() -> void:
	EventBus.expedition_started.emit()
