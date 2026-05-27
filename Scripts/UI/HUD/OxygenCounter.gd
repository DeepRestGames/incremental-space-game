extends Control

@onready var progress_bar: ProgressBar = $HBoxContainer/ProgressBar
@onready var pct_label: Label = $HBoxContainer/PctLabel

func _ready() -> void:
	hide()
	EventBus.connect("update_oxygen_HUD", on_update_oxygen)
	EventBus.connect("expedition_started", on_expedition_started)
	EventBus.connect("expedition_ended", on_expedition_ended)
	
	if GameManager.expedition_started:
		show()


func on_update_oxygen(current: float, max_val: float) -> void:
	if not visible:
		show()
	var pct = (current / max_val) * 100.0
	progress_bar.max_value = max_val
	progress_bar.value = current
	pct_label.text = "%d%%" % int(pct)


func on_expedition_started() -> void:
	show()


func on_expedition_ended() -> void:
	hide()
