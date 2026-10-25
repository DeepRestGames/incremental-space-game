class_name ProcessorTooltip
extends PanelContainer

@onready var _recipe_row: HBoxContainer = %RecipeRow
@onready var _in_text: Label = %InText
@onready var _in_icon: TextureRect = %InIcon
@onready var _out_text: Label = %OutText
@onready var _out_icon: TextureRect = %OutIcon
@onready var _desc_label: Label = %DescLabel


func show_text(anchor: Control, text: String) -> void:
	_recipe_row.hide()
	_desc_label.text = text
	_place_below(anchor)


func show_recipe(anchor: Control, recipe: ConversionRecipe) -> void:
	var mat: ResourceType = recipe.input_type()
	_in_text.text = "%dx" % recipe.input_amount()
	_in_icon.texture = mat.icon if mat else null
	_out_text.text = "→ %dx" % recipe.output_amount
	_out_icon.texture = recipe.output.icon if recipe.output else null
	_recipe_row.show()
	_desc_label.text = mat.description if mat else ""
	_place_below(anchor)


func _place_below(anchor: Control) -> void:
	show()
	reset_size()
	var rect: Rect2 = anchor.get_global_rect()
	global_position = Vector2(
		rect.get_center().x - size.x * 0.5,
		rect.end.y + 15.0
	)
