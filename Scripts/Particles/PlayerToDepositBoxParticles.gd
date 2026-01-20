extends GPUParticles2D


var source_position: Vector2
var target_position: Vector2


func _ready() -> void:
	target_position = GameManager.deposit_box_position
	
	EventBus.connect("start_resource_transfer_animation_to_deposit_box", start_animation)


func _physics_process(delta: float) -> void:
	source_position = GameManager.player.global_position
	
	var direction = source_position.direction_to(target_position)
	
	process_material.direction = Vector3(direction.x, direction.y, 0)


func start_animation(resource_value: int) -> void:
	if resource_value > 0:
		amount = resource_value
		# speed_scale = 50 / amount
		restart()
