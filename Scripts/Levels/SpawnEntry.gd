@tool
class_name SpawnEntry
extends Resource

## One rock type a planet can spawn.

@export var scene: PackedScene
## Relative chance: a rock with 4 is four times as likely as one with 1.
@export var weight: float = 1.0
## Optional skill stat that scales this weight on this planet, e.g.
## e.g. "bastet_common_weight". Leave empty if no skill should touch it.
@export var weight_stat: String = ""


## Turns weight_stat into a dropdown of the spawn-weight stats that exist, so a
## typo can't silently mean "no skill applies". Runs in the editor, which is
## why this script is @tool.
func _validate_property(property: Dictionary) -> void:
	if property.name != "weight_stat":
		return
	var options: Array[String] = [""]  # first entry: no stat
	for stat_id in BaseValuesDB.BASE_VALUES:
		if stat_id.ends_with("_weight"):
			options.append(stat_id)
	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = ",".join(options)
