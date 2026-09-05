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
@onready var sprite_canvas: CanvasGroup = $CanvasGroup
@onready var sprite_2d: Sprite2D = $CanvasGroup/Sprite2D
@export var rock_sprites: Array[Texture2D]
#endregion

#region drops
## Un "tiro" di drop fortunato vale un tick di trivella a danno base.
## Con piu danno si tira piu volte nello stesso tick, cosi il numero totale di
## tiri su un sasso dipende dai suoi HP e non da quanto e forte il giocatore.
const ROLL_DAMAGE_UNIT: float = BaseValuesDB.DRILL_DAMAGE_PER_TICK

@export_group("Drops")
## Cosa droppa questo breakable. Tutte le entry droppano sempre.
@export var drops: Array[DropEntry] = []

## Pezzi garantiti alla distruzione, uno per ogni entry di `drops`.
## Tirato alla nascita e mai più modificato
var _amounts: Array[int] = []
#endregion

#region spawn containers
var _pickup_parent: Node
var _particle_parent: Node
var _damage_number_parent: Node

func _resolve_container(path: String) -> Node:
	var container := get_tree().current_scene.get_node_or_null(path)
	if container:
		return container
	push_warning("%s: '%s' non trovato, uso la radice della scena" % [name, path])
	return get_tree().current_scene
	
## Tira il contenuto del sasso una volta sola, e valida la configurazione
## adesso invece che al primo colpo.
func _roll_contents() -> void:
	_amounts.resize(drops.size())
	for i in drops.size():
		var entry := drops[i]
		if not entry or not entry.scene:
			push_error("%s: drops[%d] senza scena assegnata" % [name, i])
			_amounts[i] = 0
			continue
		_amounts[i] = randi_range(entry.min_amount, entry.max_amount)
#endregion


func _ready() -> void:
	currentHP = totalHP
	_roll_contents()
	
	# THIS ONLY WORKS AS LONG AS THERE ARE ONLY 2 TEXTURES AVAILABLE AND THEY ARE SPECULAR (FLIPPED HORIZONTALLY)
	var random_index = randi_range(0, 1)
	sprite_2d.texture = rock_sprites[random_index]
	
	EventBus.action_trigger_interact.connect(on_interacted)
	
	_pickup_parent = _resolve_container("Objects/Pickups")
	_particle_parent = _resolve_container("Objects/Particles")
	_damage_number_parent = _resolve_container("Objects/DamageNumbers")
	
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
	
	#hurt animation
	var squish_scale = 0.9
	var default_scale = sprite_2d.scale
	var _default_color = sprite_2d.modulate
	var tween_scale = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_scale.tween_property(sprite_2d, "scale", default_scale*squish_scale, 0.07)
	tween_scale.tween_property(sprite_2d, "scale", default_scale, 0.07)
	var tween_modulate = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_modulate.tween_property(sprite_canvas, "instance_shader_parameters/flash_value", 0.85, 0.05)
	tween_modulate.tween_property(sprite_canvas, "instance_shader_parameters/flash_value", 0, 0.2)
	
	spawn_rock_particles(randi_range(min_rock_particles, max_rock_particles))

	# Il danno oltre gli HP rimasti non conta: senza questo, il colpo che sfonda
	# un sasso quasi morto regalerebbe tiri per danno mai realmente inflitto.
	var effective_damage := float(mini(damage_value, currentHP))
	var rolls := effective_damage / ROLL_DAMAGE_UNIT

	for entry_index in drops.size():
		var entry := drops[entry_index]
		if not entry.drops_while_drilling:
			continue
		var chance := SkillModifiers.get_drop_chance_per_tick(entry.chance_per_drill_tick)
		if chance <= 0.0:
			continue

		# parte intera dei tiri, piu la frazione decisa a sorte: cosi il valore
		# atteso resta esatto anche quando i tiri spettanti non sono un intero.
		var n := int(rolls)
		if randf() < rolls - float(n):
			n += 1
		for i in n:
			if randf() < chance:
				spawn_drop(entry_index, 1)

	currentHP -= damage_value
	
	if currentHP <= 0 and !is_dead:
		die()

	else:
		hit.play()


func spawn_drop(entry_index: int, amount: int) -> void:
	if amount <= 0:
		return
	var entry := drops[entry_index]
	if not entry or not entry.scene:
		return

	for i in amount:
		var pickup := entry.scene.instantiate() as BasePickup
		# non è più preload quindi si controlla
		if not pickup:
			push_error("%s: %s non ha un BasePickup come root" % [name, entry.scene.resource_path])
			return
		var random_offset := Vector2(randf_range(-40, 40), 0.0)
		_pickup_parent.add_child(pickup)
		pickup.global_position = global_position + random_offset
		pickup.randomize_spawn_direction()


func spawn_rock_particles(rock_particles_number: int) -> void:
	for i in rock_particles_number:
		var rock_particle_node = rock_particle.instantiate() as RockParticle
		var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		_particle_parent.add_child(rock_particle_node) 
		rock_particle_node.global_position = self.global_position + random_offset
		rock_particle_node.randomize_spawn_direction()


func spawn_damage_number(damage_amount: int, is_crit: bool) -> void:
	var number := DAMAGE_NUMBER.instantiate() as DamageNumber
	_damage_number_parent.add_child(number)  
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
	var extra_drops := int(SkillModifiers.get_drops_on_destruction())

	for entry_index in drops.size():
		spawn_drop(entry_index, _amounts[entry_index] + extra_drops)
	
	hide()
	set_physics_process(false)
	set_process(false)
	
	collision_shape_2d.set_deferred("disabled", true)
	
	destroy.play()
	await destroy.finished
	
	queue_free()
