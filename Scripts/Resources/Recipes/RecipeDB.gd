class_name RecipeDB

# Question: can I not look on the files in the folder somehow?
const ALL: Array[ConversionRecipe] = [
preload("res://GameResources/Recipes/white_triangle_to_chip.tres"),
preload("res://GameResources/Recipes/white_square_to_chips.tres"),
]

# currently inactive recipes. Drag into ALL to activate
# preload("res://GameResources/Recipes/blue_diamond_to_chips.tres"),


# helper to find what station has what recipe
static func recipes_for(station: StringName) -> Array[ConversionRecipe]:
	var out: Array[ConversionRecipe] = []
	for r in ALL:
		if r.station == station:
			out.append(r)
	return out
