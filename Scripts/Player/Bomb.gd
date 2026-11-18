extends Node2D


@onready var animation_player = $AnimationPlayer
@onready var hitbox_area = $HitboxArea
@onready var sprite = $CanvasGroup
@onready var explosion_particles = $ExplosionParticles



func _ready() -> void:
	animation_player.play("tick_boom")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# guard
	if anim_name != "tick_boom":
		return

	explosion_particles.emitting = true
	sprite.visible = false

	for body in hitbox_area.get_overlapping_bodies():
		if body is Breakable:
			body.take_damage(int(SkillModifiers.get_bomb_damage()), false)


func _on_explosion_particles_finished() -> void:
	queue_free.call_deferred()
