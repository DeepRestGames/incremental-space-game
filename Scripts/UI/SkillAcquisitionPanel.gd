extends Control




func _ready() -> void:
	EventBus.connect("skillNodePressed", show)
	EventBus.connect("skillNodeExited", hide)
