extends Node


var current_player_resource: int = 0


func _ready() -> void:
	EventBus.connect("add_resource", add_resource)


func add_resource(resource_number: int) -> void:
	current_player_resource += resource_number
	
	print("Added resource")
	print("Total resources: " + str(current_player_resource))
