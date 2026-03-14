extends Node2D


@onready var animation_player = $AnimationPlayer
@onready var hitbox_area = $HitboxArea
@onready var sprite = $Sprite2D
@onready var explosion_particles = $ExplosionParticles

@export var bomb_damage = 3


func _ready() -> void:
	animation_player.play("tick_boom")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	explosion_particles.emitting = true
	sprite.visible = false
	if anim_name == "tick_boom":
		for body in hitbox_area.get_overlapping_bodies():
			#if body.is_in_group("Player"):
				#body.take_damage(1)
			
			print("Overlapping body:")
			print(body.name)
			
			if body is Breakable:
				print("BODY IS BREAKABLE")
				body.take_damage(3)
	

func _on_explosion_particles_finished() -> void:
	call_deferred("queue_free")
