class_name MiningReticle
extends Area2D

# Config
@export var outer_radius: float = 120.0
var inner_radius: float = 30.0

# State
var is_active: bool = false
var reticle_angle: float = 0.0

# Child node references
@onready var outer_circle: Sprite2D = $OuterCircle
@onready var guide_line: Line2D = $GuideLine
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var digging_circle: Sprite2D = $DiggingCircle

func _ready() -> void:
	# Add to the MiningReticle group so Breakables can identify it
	add_to_group("MiningReticle")
	
	# Read the inner_radius dynamically from the editor-configured shape
	if collision_shape and collision_shape.shape is CircleShape2D:
		inner_radius = collision_shape.shape.radius
	
	# Default state is inactive and hidden
	visible = false
	if collision_shape:
		collision_shape.disabled = true
	
	# Set process
	set_process(true)


func activate() -> void:
	is_active = true
	visible = true
	if collision_shape:
		collision_shape.disabled = false


func deactivate() -> void:
	is_active = false
	visible = false
	if collision_shape:
		collision_shape.disabled = true


func _process(_delta: float) -> void:
	if not is_active:
		return
		
	# Follow the mouse direction relative to the player
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	
	var dir = (mouse_pos - player_pos)
	if dir.length_squared() > 1.0:
		reticle_angle = dir.angle()
		
	# Update collision shape and sprite positions (local space)
	var local_target_pos = Vector2.from_angle(reticle_angle) * outer_radius
	if collision_shape:
		collision_shape.position = local_target_pos
	if digging_circle:
		digging_circle.position = local_target_pos
		
	# Update guide line points
	if guide_line:
		guide_line.points = PackedVector2Array([Vector2.ZERO, local_target_pos])
