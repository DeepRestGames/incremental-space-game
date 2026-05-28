class_name SkillNode
extends Control


@export var parent_node: SkillNode
var width : int = 10
var color : Color = Color.GREEN


#func _ready() -> void:
	#queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	
	print("current node: " + name)
	
	
	if parent_node != null:
		
		print("Parent is not null")
	
		var pivot_point = Vector2(size.x/2, size.y/2)
		var parent_position = Vector2(parent_node.position - position) + pivot_point
		
		draw_line(pivot_point, parent_position, color, width)
