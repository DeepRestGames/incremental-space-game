class_name RecipeDB

# Question: can I not look on the files in the folder somehow?
const ALL: Array[ConversionRecipe] = [
preload("uid://cwghoc8usrrju"),
preload("uid://dtn2pksnemkeb"),
preload("uid://durq7non06fxf")
]
# helper to find what station has what recipe
static func recipes_for(station: StringName) -> Array[ConversionRecipe]:
	var out: Array[ConversionRecipe] = []
	for r in ALL:
		if r.station == station:
			out.append(r)
	return out
