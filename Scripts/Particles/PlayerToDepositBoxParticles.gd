extends GPUParticles2D


var source_position: Vector2
var target_position: Vector2


func _ready() -> void:
	target_position = GameManager.deposit_box_position
	
	EventBus.connect("player_enter_deposit_box_area", start_animation)


func _physics_process(delta: float) -> void:
	source_position = GameManager.player.global_position
	
	var direction = source_position.direction_to(target_position)
	
	process_material.direction = Vector3(direction.x, direction.y, 0)


func start_animation() -> void:
	if GameManager.current_player_resource > 0:
		amount = GameManager.current_player_resource
		restart()
		emitting = true
