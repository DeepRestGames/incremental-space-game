class_name Breakable
extends StaticBody2D


@export var totalHP: int = 3
var currentHP: int

@onready var control: Control = $Control
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var player_is_in_range: bool = false

@onready var hit: AudioStreamPlayer = $Audio/Hit
@onready var destroy: AudioStreamPlayer = $Audio/Destroy

@onready var rock_particle = preload("res://Scenes/Particles/rock_particle.tscn")
@export var min_rock_particles = 3
@export var max_rock_particles = 7

@onready var sprite_2d: Sprite2D = $CollisionShape2D/Sprite2D
@export var rock_sprites: Array[Texture2D]

@onready var resource_scene: PackedScene = preload("res://Scenes/Resources/BasePickup.tscn")
@export var min_resource_number: int = BaseValuesDB.MIN_RESOURCE_NUMBER
@export var max_resource_number: int = BaseValuesDB.MAX_RESOURCE_NUMBER
var current_resource_number: int
@export var resource_spawn_chance_on_damaged: float = BaseValuesDB.RESOURCE_SPAWN_CHANCE_ON_DAMAGED


func _ready() -> void:
	currentHP = totalHP
	current_resource_number = randi_range(min_resource_number, max_resource_number)
	
	sprite_2d.texture = rock_sprites.pick_random()
	
	EventBus.action_trigger_interact.connect(on_interacted)
	
	var area2d = get_node_or_null("CollisionShape2D/Sprite2D/Area2D")
	if area2d:
		area2d.area_entered.connect(_on_area_entered)
		area2d.area_exited.connect(_on_area_exited)


func on_interacted() -> void:
	if not player_is_in_range:
		return
	
	var damage = int(SkillModifiers.get_drill_damage_per_tick())
	
	# Crit chance check
	var crit_chance = SkillModifiers.get_drill_crit_chance()
	if randf() < crit_chance:
		var crit_mult = SkillModifiers.get_drill_crit_damage()
		damage = int(damage * crit_mult)
	
	take_damage(damage)


func take_damage(damage_value: int) -> void:
	EventBus.breakable_damaged.emit()
	
	# drop_chance_per_tick adds to base drop chance
	var drop_chance = SkillModifiers.get_drop_chance_per_tick(resource_spawn_chance_on_damaged)
		
	spawn_rock_particles(randi_range(min_rock_particles, max_rock_particles))
		
	for i in damage_value:
		
		
		if randf() < drop_chance:
			spawn_resource_drops(1)
	
	currentHP -= damage_value
	
	if currentHP <= 0:
		if GameManager.expedition_started:
			GameManager.expedition_destroyed_nodes += 1
		destroy.play()
		
		# Extra drops on destruction from skill upgrades
		var extra_drops = int(SkillModifiers.get_drops_on_destruction())
			
		spawn_resource_drops(current_resource_number + extra_drops)
		queue_free()
	else:
		hit.play()


func spawn_resource_drops(resource_number: int) -> void:
	for i in resource_number:
		var resource_drop_node = resource_scene.instantiate() as BasePickup
		var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
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
		
