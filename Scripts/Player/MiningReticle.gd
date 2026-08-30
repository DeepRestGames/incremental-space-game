class_name MiningReticle
extends Area2D

# Config
@export var outer_radius: float = 100.0
var inner_radius: float = 30.0

# State
var is_active: bool = true
var reticle_angle: float = 0.0

# Child node references
@onready var outer_circle: Sprite2D = $OuterCircle
@onready var guide_line: Line2D = $GuideLine
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var digging_circle: Sprite2D = $DiggingCircle

#region Crit coloring
## Shader uniforms carrying the reticle colour. All three share one value.
const COLOR_PARAMS: Array[String] = ["circle_color_main", "dot_color", "cross_color_main"]

@export var crit_flash_color: Color = Color(1, 0.78, 0.2)
@export var crit_flash_time: float = 0.5

var _base_color: Color
var _crit_tween: Tween
#endregion

func _ready() -> void:
	# Add to the MiningReticle group so Breakables can identify it
	add_to_group("MiningReticle")
	
	update_reticle_size()
	
	# Set process
	set_process(true)
	
	digging_circle.material = digging_circle.material.duplicate()
	_base_color = digging_circle.material.get_shader_parameter(COLOR_PARAMS[0])
	
	EventBus.breakable_damaged.connect(on_breakable_damaged)
	
func on_breakable_damaged(_damage_amount: int, is_crit: bool) -> void:
	if not is_crit or not is_active:
		return
	if _crit_tween:
		_crit_tween.kill()

	_crit_tween = create_tween().set_parallel(true)
	for param in COLOR_PARAMS:
		digging_circle.material.set_shader_parameter(param, crit_flash_color)
		_crit_tween.tween_property(digging_circle.material,
			"shader_parameter/%s" % param, _base_color, crit_flash_time)

func update_reticle_size() -> void:
	var base_radius = BaseValuesDB.DRILL_AREA_SIZE
	inner_radius = SkillModifiers.get_drill_area_size(base_radius)
	
	# Update collision shape radius
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = inner_radius
		
	# Update visual sprite scale dynamically (512x512 texture base)
	if digging_circle:
		var new_scale = (2.0 * inner_radius) / 512.0
		digging_circle.scale = Vector2(new_scale, new_scale)


func _process(_delta: float) -> void:
	#if not is_active:
		#return
		
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
		
		


			
