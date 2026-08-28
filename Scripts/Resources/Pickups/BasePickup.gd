class_name BasePickup
extends Area2D

#Graphics
@onready var animation_player_glow = $AnimationPlayerGlow
@onready var animation_player_shine_spikes = $AnimationPlayerShineSpikes
@onready var sprite_2d: Sprite2D = $Sprite2D


@export_group("Pickup Info")
@export var pickup_amount: int = 1

@export_group("Player attraction")
var player_in_attraction_area: bool = false
var player_is_touching: bool = false
@export var movement_speed: float = 200


func _ready() -> void:
	#Initialize glowing animation
	play_randomized_animation (animation_player_glow)
	play_randomized_animation (animation_player_shine_spikes)


func play_randomized_animation (aniamtion: AnimationPlayer):
	var random_time = randf_range(0.0, aniamtion.current_animation_length)
	var random_speed = randf_range(0.9, 1.1)
	aniamtion.seek(random_time, true)
	aniamtion.speed_scale = random_speed
	aniamtion.play()
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_is_touching = true
		try_collect()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_is_touching = false


## Hands over as much as fits in the player's inventory. Whatever does not fit
## stays in this pickup, so it can be collected later once space frees up.
func try_collect() -> void:
	var accepted = GameManager.add_resource(pickup_amount)
	if accepted <= 0:
		return

	pickup_amount -= accepted
	if pickup_amount <= 0:
		queue_free()


func _physics_process(delta: float) -> void:
	if player_is_touching:
		# body_entered does not fire again for a body that is already overlapping,
		# so the leftover of a partial pickup is retried here instead: it gets
		# collected as soon as the player frees up inventory space.
		try_collect()
	elif player_in_attraction_area and not GameManager.is_inventory_full():
		if GameManager.player:
			global_position = global_position.move_toward(GameManager.player.global_position, delta * movement_speed)


func _on_move_to_player_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attraction_area = true


func _on_move_to_player_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attraction_area = false


func randomize_spawn_direction() -> void:
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var spawn_linear_velocity = randi_range(120, 300)
	var spawn_angular_velocity = randf_range(2, 5)
	var spawn_duration = randf_range(.5, 1)
	
	#sprite starting y position (= starting fake z)
	var starting_z = randf_range(-10, -50)
	var z_height = randf_range(50, 100)
	sprite_2d.position.y = starting_z
	
	var tween_y = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "position:y", position.y + (direction.y * spawn_linear_velocity), spawn_duration)
	
	#fake z movement
	var tween_z = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween_z.tween_property(sprite_2d, "position:y", starting_z - z_height, spawn_duration/4).set_trans(Tween.TRANS_CUBIC)
	tween_z.tween_property(sprite_2d, "position:y", 0, spawn_duration/4*3).set_trans(Tween.TRANS_BOUNCE)
	
	var tween_x = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "position:x", position.x + (direction.x * spawn_linear_velocity), spawn_duration)
	
	var tween_rotation = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_rotation.tween_property(sprite_2d, "rotation", rotation + spawn_angular_velocity, spawn_duration)
