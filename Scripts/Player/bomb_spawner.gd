class_name BombSpawner
extends Node2D


@onready var bomb_scene = preload("res://Scenes/Bombs/Bomb.tscn")


func spawn_bomb(spawn_global_position: Vector2) -> void:
	var bomb_node = bomb_scene.instantiate()
	bomb_node.global_position = spawn_global_position
	get_tree().root.add_child(bomb_node)
