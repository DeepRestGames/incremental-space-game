extends Node


var current_points: int = 0
var points_increment_value: int = 1
var increment_points_active: bool = false
var points_increment_cooldown: float = 1.0
var points_increment_cooldown_counter: float



func _ready() -> void:
	reset_increment_points_cooldown_counter()
	
	EventBus.connect("player_enter_capture_area", on_player_enter_capture_area)
	EventBus.connect("player_exit_capture_area", on_player_exit_capture_area)


func _process(delta: float) -> void:
	if increment_points_active:
		points_increment_cooldown_counter -= delta
		
		if points_increment_cooldown_counter <= 0:
			current_points += points_increment_value
			reset_increment_points_cooldown_counter()
			
			print("NEW POINT! CURRENT: " + str(current_points))


func reset_increment_points_cooldown_counter() -> void:
	points_increment_cooldown_counter = points_increment_cooldown


func on_player_enter_capture_area() -> void:
	increment_points_active = true


func on_player_exit_capture_area() -> void:
	increment_points_active = false
	reset_increment_points_cooldown_counter()
