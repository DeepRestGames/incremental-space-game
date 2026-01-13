extends Node

# Player
var current_player_resource: int = 0

# DepositBox
var current_deposit_box_resource: int = 0




func _ready() -> void:
	EventBus.connect("add_resource", add_resource)
	EventBus.connect("player_enter_deposit_box", add_resource_deposit_box)


func add_resource(resource_amount: int) -> void:
	current_player_resource += resource_amount
	
	print("Added resource")
	print("Total resources: " + str(current_player_resource))


func add_resource_deposit_box() -> void:
	current_deposit_box_resource += current_player_resource
	current_player_resource = 0
	
	print("Deposit box filled")
	print("Total deposit box resources: " + str(current_deposit_box_resource))
