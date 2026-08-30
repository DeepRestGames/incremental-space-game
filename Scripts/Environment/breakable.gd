class_name Breakable
extends StaticBody2D

#region Rock stats
@export var totalHP: int = 3
var currentHP: int
var is_dead: bool = false
#endregion

#region collisions
@onready var control: Control = $Control
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var player_is_in_range: bool = false
#endregion

#region audio
@onready var hit: AudioStreamPlayer = $Audio/Hit
@onready var destroy: AudioStreamPlayer = $Audio/Destroy
#endregion

#region on damaged 
# Particles
@onready var rock_particle = preload("res://Scenes/Particles/rock_particle.tscn")
@export var min_rock_particles = 3
@export var max_rock_particles = 7

# Damage number
const DAMAGE_NUMBER := preload("res://Scenes/UI/DamageNumber.tscn")

#endregion

#region sprite
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var rock_sprites: Array[Texture2D]
#endregion

#region drops
@onready var resource_scene: PackedScene = preload("res://Scenes/Resources/BasePickup.tscn")
@export var min_resource_number: int = BaseValuesDB.MIN_RESOURCE_NUMBER
@export var max_resource_number: int = BaseValuesDB.MAX_RESOURCE_NUMBER
var current_resource_number: int
@export var resource_spawn_chance_on_damaged: float = BaseValuesDB.RESOURCE_SPAWN_CHANCE_ON_DAMAGED
#endregion



func _ready() -> void:
	currentHP = totalHP
	current_resource_number = randi_range(min_resource_number, max_resource_number)
	
	# THIS ONLY WORKS AS LONG AS THERE ARE ONLY 2 TEXTURES AVAILABLE AND THEY ARE SPECULAR (FLIPPED HORIZONTALLY)
	var random_index = randi_range(0, 1)
	sprite_2d.texture = rock_sprites[random_index]
	
	EventBus.action_trigger_interact.connect(on_interacted)
	
	var area2d = get_node_or_null("Area2D")
	if area2d:
		area2d.area_entered.connect(_on_area_entered)
		area2d.area_exited.connect(_on_area_exited)
	
	# flip the colliders if the second rock texture has been assigned
	if random_index == 1:
		collision_shape_2d.scale.x *= -1
		area2d.scale.x *= -1


func on_interacted() -> void:
	if not player_is_in_range:
		return

	var damage := int(SkillModifiers.get_drill_damage_per_tick())
	# Crit chance check
	var is_crit := randf() < SkillModifiers.get_drill_crit_chance()
	if is_crit:
		damage = int(damage * SkillModifiers.get_drill_crit_damage())
	
	take_damage(damage, is_crit)
	spawn_damage_number(damage, is_crit)


func take_damage(damage_value: int, is_crit: bool) -> void:
	EventBus.breakable_damaged.emit(damage_value, is_crit)
	
	# drop_chance_per_tick adds to base drop chance
	var drop_chance = SkillModifiers.get_drop_chance_per_tick(resource_spawn_chance_on_damaged)
		
	spawn_rock_particles(randi_range(min_rock_particles, max_rock_particles))
		
	for i in damage_value:
		
		if randf() < drop_chance:
			spawn_resource_drops(1)
	
	currentHP -= damage_value
	
	if currentHP <= 0 and !is_dead:
		die()

	else:
		hit.play()


func spawn_resource_drops(resource_number: int) -> void:
	for i in resource_number:
		var resource_drop_node = resource_scene.instantiate() as BasePickup
		var random_offset = Vector2(randf_range(-40, 40), randf_range(0, 0))
		get_tree().current_scene.add_child(resource_drop_node)
		resource_drop_node.global_position = self.global_position + random_offset
		resource_drop_node.randomize_spawn_direction()
	
	current_resource_number -= resource_number


func spawn_rock_particles(rock_particles_number: int) -> void:
	for i in rock_particles_number:
		var rock_particle_node = rock_particle.instantiate() as RockParticle
		var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_tree().current_scene.get_node("Objects/Particles").add_child(rock_particle_node)
		rock_particle_node.global_position = self.global_position + random_offset
		rock_particle_node.randomize_spawn_direction()


func spawn_damage_number(damage_amount: int, is_crit: bool) -> void:
	var number := DAMAGE_NUMBER.instantiate() as DamageNumber
	get_tree().current_scene.get_node("Objects/DamageNumbers").add_child(number)
	number.global_position = global_position
	number.show_damage(damage_amount, is_crit)
	

func _on_area_2d_body_entered(_body: Node2D) -> void:
	pass


func _on_area_2d_body_exited(_body: Node2D) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("MiningReticle"):
		#control.show()
		player_is_in_range = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("MiningReticle"):
		#control.hide()
		player_is_in_range = false


func die () -> void:
	is_dead = true
	if GameManager.expedition_started:
		GameManager.expedition_destroyed_nodes += 1
	
	# Extra drops on destruction from skill upgrades
	var extra_drops = int(SkillModifiers.get_drops_on_destruction())
	
	spawn_resource_drops(current_resource_number + extra_drops)
	
	hide()
	set_physics_process(false)
	set_process(false)
	
	collision_shape_2d.set_deferred("disabled", true)
	
	destroy.play()
	await destroy.finished
	
	queue_free()
