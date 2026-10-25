class_name RecipeDB

# The reason const ALL = [preload(...)] is preferred for the main list is that preload() 
# bakes the references at compile time and works reliably in exported .pck builds without scanning folders at runtim
const ALL: Array[ConversionRecipe] = [
preload("res://GameResources/Recipes/white_triangle_to_chip.tres"),
preload("res://GameResources/Recipes/white_square_to_chips.tres"),
preload("res://GameResources/Recipes/blue_diamond_to_chips.tres"),
]

# currently inactive recipes. Drag into ALL to activate



# helper to find what station has what recipe
static func recipes_for(station: StringName) -> Array[ConversionRecipe]:
	var out: Array[ConversionRecipe] = []
	for r in ALL:
		if r.station == station:
			out.append(r)
	return out

## Finds the recipe at `station` that consumes `material`, or null.
static func recipe_for_input(material: ResourceType, station: StringName = &"processor") -> ConversionRecipe:
	for r in ALL:
		if r.station == station and r.input_type() == material:
			return r
	return null
