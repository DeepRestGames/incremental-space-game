extends Control


@onready var skillInfoPanel = $SkillInfoPanel

var disabled = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			disabled = true
			EventBus.emit_signal("skillNodePressed")


func _ready() -> void:
	connect("mouse_entered", on_mouse_enter)
	connect("mouse_exited", on_mouse_exit)


func on_mouse_enter() -> void:
	print("Mouse enter")
	skillInfoPanel.show()


func on_mouse_exit() -> void:
	if disabled:
		return
	
	print("Mouse exit")
	EventBus.emit_signal("skillNodeExited")
	
	skillInfoPanel.hide()
