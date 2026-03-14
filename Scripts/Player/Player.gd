class_name Player
extends CharacterBody2D


# Camera
var default_camera_zoom = Vector2.ONE

# Graphics
@onready var player_sprite = $PlayerSprite
@onready var animation_player = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


# HP
var currentHP: int = 3
@export var maxHP: int = 3
var invincibilityCooldown := .5
var currentInvincibilityCooldown: float

# Movement
@export var movement_speed: float = 300
var looking_direction = Vector2.ZERO
var movement_direction = Vector2.ZERO
const ROTATION_SPEED: float = 2

# Consumables
var fabricator_material_quantity: int = 100
var powerup_chips_quantity: int = 0


func _ready() -> void:	
	#EventBus.connect("add_fabricator_material", add_fabricator_material)
	#EventBus.connect("remove_fabricator_material", remove_fabricator_material)
	
	send_HUD_update_data()
	
	#EventBus.connect("player_respawned", on_player_respawned)
	#EventBus.connect("show_ship_menu", on_player_returned_to_ship)
	
	#EventBus.connect("hide_player", hide_player)
	
	# Input signals
	#EventBus.connect("looking_direction_changed", update_looking_direction)
	EventBus.connect("player_movement", update_movement_direction)
	
	# Animations
	animation_tree.active = true
	
	EventBus.emit_signal("on_player_ready", self)


func update_looking_direction(new_looking_direction: Vector2) -> void:
	looking_direction = new_looking_direction


func update_movement_direction(new_movement_direction: Vector2) -> void:
	velocity = new_movement_direction * movement_speed
	movement_direction = new_movement_direction


func _process(delta: float) -> void:
	if currentInvincibilityCooldown > 0:
		currentInvincibilityCooldown -= delta
	update_animation_parameters()


func _physics_process(_delta: float) -> void:
	move_and_slide()


func take_damage(value) -> void:
	if currentInvincibilityCooldown > 0:
		return
	
	remove_hp(value)
	currentInvincibilityCooldown = invincibilityCooldown
	
	var blinking_player_tween = get_tree().create_tween().set_parallel(false)
	blinking_player_tween.tween_property(player_sprite, "visible", false, invincibilityCooldown / 5)
	blinking_player_tween.tween_property(player_sprite, "visible", true, invincibilityCooldown / 5)
	blinking_player_tween.tween_property(player_sprite, "visible", false, invincibilityCooldown / 5)
	blinking_player_tween.tween_property(player_sprite, "visible", true, invincibilityCooldown / 5)
	blinking_player_tween.tween_property(player_sprite, "visible", false, invincibilityCooldown / 5)
	blinking_player_tween.tween_property(player_sprite, "visible", true, .001)


func add_fabricator_material(value) -> void:
	fabricator_material_quantity += value
	EventBus.emit_signal("update_current_fabricator_material_count", fabricator_material_quantity)


func remove_fabricator_material(value) -> void:
	if value > fabricator_material_quantity:
		printerr("Not enough fabricator material!")
		return
	
	fabricator_material_quantity -= value
	EventBus.emit_signal("update_current_fabricator_material_count", fabricator_material_quantity)


func add_hp(value) -> void:
	currentHP += value
	EventBus.emit_signal("update_current_hp_HUD", currentHP)


func remove_hp(value) -> void:
	currentHP -= value
	EventBus.emit_signal("update_current_hp_HUD", currentHP)
	
	if currentHP <= 0:
		clearConsumables()
		EventBus.emit_signal("player_death")
		call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)


func clearConsumables() -> void:
	fabricator_material_quantity = 0
	powerup_chips_quantity = 0
	send_HUD_update_data()


func on_player_respawned() -> void:
	full_hp()
	call_deferred("set_process_mode", Node.PROCESS_MODE_INHERIT)


func on_player_returned_to_ship(value) -> void:
	if value == true:
		full_hp()
		send_HUD_update_data()
		
		EventBus.emit_signal("clear_map_from_enemies")


func full_hp() -> void:
	currentHP = maxHP
	EventBus.emit_signal("update_current_hp_HUD", currentHP)



func heal_hp() -> void:
	if currentHP == maxHP:
		return
	
	currentHP += 1
	EventBus.emit_signal("update_current_hp_HUD", currentHP)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		take_damage(1)
	elif body.is_in_group("EnemyProjectiles"):
		body.queue_free()
		take_damage(1)


func send_HUD_update_data() -> void:
	pass
	#EventBus.emit_signal("update_current_fabricator_material_count", fabricator_material_quantity)
	#EventBus.emit_signal("update_current_powerup_chips_count", powerup_chips_quantity)
	#EventBus.emit_signal("update_current_hp_HUD", currentHP)


func hide_player(value) -> void:
	if value:
		hide()
		EventBus.emit_signal("set_prevent_inputs", true)
	else:
		show()
		EventBus.emit_signal("set_prevent_inputs", false)

func update_animation_parameters():
	if (velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	if Input.is_action_pressed("interact") :
		animation_tree["parameters/conditions/drilling"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = false
	else :
		animation_tree["parameters/conditions/drilling"] = false
	
	if movement_direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = movement_direction
		animation_tree["parameters/Run/blend_position"] = movement_direction
		animation_tree["parameters/Drill/blend_position"] = movement_direction
