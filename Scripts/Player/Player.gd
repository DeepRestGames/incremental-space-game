class_name Player
extends CharacterBody2D


# Camera
@onready var player_camera: Camera2D = $PlayerCamera

# Graphics
@onready var player_sprite = $PlayerSprite
@onready var animation_tree: AnimationTree = $AnimationTree

# HP
@export var maxHP: int = BaseValuesDB.MAX_HP
var currentHP: int = BaseValuesDB.MAX_HP:
	set(value):
		currentHP = clampi(value, 0, maxHP)
		EventBus.update_current_hp_HUD.emit(currentHP)
var invincibilityCooldown: float = BaseValuesDB.INVINCIBILITY_COOLDOWN
var currentInvincibilityCooldown: float

# Movement
@export var movement_speed: float = BaseValuesDB.MOVEMENT_SPEED
@export var mining_speed_multiplier: float = BaseValuesDB.MINING_SPEED_MULTIPLIER
var movement_direction = Vector2.ZERO
var inside_interactable_area: bool = false
var mining_reticle: Area2D

# Consumables
var fabricator_material_quantity: int = BaseValuesDB.STARTING_FABRICATOR_MATERIAL
var powerup_chips_quantity: int = BaseValuesDB.STARTING_POWERUP_CHIPS

# Oxygen
@export var max_oxygen: float = BaseValuesDB.OXYGEN_TANK_CAPACITY
@export var base_oxygen_drain_rate: float = BaseValuesDB.BASE_OXYGEN_DRAIN_RATE
var current_oxygen: float = BaseValuesDB.OXYGEN_TANK_CAPACITY

# Why the player died, forwarded to the expedition summary (e.g. "oxygen")
var death_reason: String = ""

# Bombs
var max_bombs: int = 0
var current_bombs: int = 0



func _ready() -> void:
	#Camera limits for lobby
	if !GameManager.expedition_started:
		player_camera.limit_left = -1100
		player_camera.limit_right = 2800
		player_camera.limit_top = -1200
		player_camera.limit_bottom = 1100

	# Input signals
	EventBus.player_movement.connect(update_movement_direction)

	# Refresh cached stats whenever a skill is bought, refunded or reset
	EventBus.stats_changed.connect(update_stats)

	# Reference existing MiningReticle child node
	mining_reticle = $MiningReticle
	
	update_stats()
	current_bombs = max_bombs
	EventBus.update_bomb_HUD.emit(current_bombs, max_bombs)
	
	# Animations
	animation_tree.active = true
	
	EventBus.on_player_ready.emit(self)


func update_stats() -> void:
	movement_speed = SkillModifiers.get_movement_speed()
	var old_max = max_oxygen
	max_oxygen = SkillModifiers.get_oxygen_tank_capacity()
	if max_oxygen != old_max:
		current_oxygen = max_oxygen
	
	# Recalculate max bombs based on skill tree upgrades
	max_bombs = int(SkillModifiers.get_bomb_charges())
	EventBus.update_bomb_HUD.emit(current_bombs, max_bombs)


func can_use_bomb() -> bool:
	return current_bombs > 0


func use_bomb() -> bool:
	if can_use_bomb():
		current_bombs -= 1
		EventBus.update_bomb_HUD.emit(current_bombs, max_bombs)
		return true
	return false


func update_movement_direction(new_movement_direction: Vector2) -> void:
	movement_direction = new_movement_direction


func _process(delta: float) -> void:
	if currentInvincibilityCooldown > 0:
		currentInvincibilityCooldown -= delta
	update_animation_parameters()

	if GameManager.expedition_started:
		mining_reticle.visible = true
		# During the opening grace period the tank stays full: the bar is still
		# refreshed so it reads 100% instead of whatever the scene was authored with.
		if GameManager.is_oxygen_draining():
			var skill_multiplier := 1.0
			if GameManager.has_method("get_oxygen_skill_multiplier"):
				skill_multiplier = GameManager.get_oxygen_skill_multiplier()

			var level_modifier := 1.0
			var current_scene = get_tree().current_scene
			if current_scene:
				var modifiers = current_scene.get_node_or_null("Modifiers")
				if modifiers and modifiers.has_method("get_oxygen_drain_multiplier"):
					level_modifier = modifiers.get_oxygen_drain_multiplier()
				elif "oxygen_drain_modifier" in current_scene:
					level_modifier = current_scene.oxygen_drain_modifier

			var actual_drain = base_oxygen_drain_rate * skill_multiplier * level_modifier
			current_oxygen = max(current_oxygen - actual_drain * delta, 0.0)

		EventBus.update_oxygen_HUD.emit(current_oxygen, max_oxygen)

		if current_oxygen <= 0.0 and currentHP > 0:
			death_reason = "oxygen"
			remove_hp(currentHP)



func _physics_process(_delta: float) -> void:
	var speed_multiplier := 1.0
	var is_drilling = Input.is_action_pressed("interact") and GameManager.expedition_started and not inside_interactable_area
	if is_drilling:
		speed_multiplier = mining_speed_multiplier
		if mining_reticle and not mining_reticle.is_active:
			mining_reticle.activate()
	else:
		if mining_reticle and mining_reticle.is_active:
			mining_reticle.deactivate()
		
	velocity = movement_direction * (movement_speed * speed_multiplier)
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


func add_hp(value: int) -> void:
	currentHP += value


func full_hp() -> void:
	currentHP = maxHP


func heal_hp() -> void:
	currentHP += 1


func remove_hp(value: int) -> void:
	currentHP -= value

	if currentHP <= 0:
		clearConsumables()
		set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
		if GameManager.expedition_started:
			GameManager.end_expedition(false, death_reason)

func clearConsumables() -> void:
	fabricator_material_quantity = 0
	powerup_chips_quantity = 0


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		take_damage(1)
	elif body.is_in_group("EnemyProjectiles"):
		body.queue_free()
		take_damage(1)


func update_animation_parameters():
	if (velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	if Input.is_action_pressed("interact") and GameManager.expedition_started and not inside_interactable_area:
		animation_tree["parameters/conditions/drilling"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = false
		if mining_reticle:
			var drill_dir = Vector2.from_angle(mining_reticle.reticle_angle)
			animation_tree["parameters/Drill/blend_position"] = drill_dir
			animation_tree["parameters/Idle/blend_position"] = drill_dir
	else :
		animation_tree["parameters/conditions/drilling"] = false
	
	if movement_direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = movement_direction
		animation_tree["parameters/Run/blend_position"] = movement_direction
		animation_tree["parameters/Drill/blend_position"] = movement_direction
