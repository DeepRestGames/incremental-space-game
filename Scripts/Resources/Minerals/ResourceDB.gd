class_name ResourceDB

const MONEY1 := preload("res://Assets/Resources/money_1.tres")
const MONEY2 := preload("res://Assets/Resources/money_2.tres")
const ORE1   := preload("res://Assets/Resources/ore_1.tres")
const ORE2   := preload("res://Assets/Resources/ore_2.tres")
const REFINED1   := preload("res://Assets/Resources/refined_1.tres")
const REFINED2   := preload("res://Assets/Resources/refined_2.tres")


const ALL: Array[ResourceType] =[MONEY1, MONEY2, ORE1, ORE2, REFINED1, REFINED2]

static var _by_id: Dictionary = {}

static func get_type(id: StringName) -> ResourceType:
	if _by_id.is_empty():
		for t in ALL:
			_by_id[t.id] = t
	return _by_id.get(id)


## Call once at startup. Catches the mistakes the preload list can't:
## empty ids, duplicates, and resources you forgot to add to ALL.
static func validate() -> void:
	var seen: Dictionary = {}
	for t in ALL:
		if t.id == &"":
			push_error("ResourceDB: %s has no id" % t.resource_path)
		elif seen.has(t.id):
			push_error("ResourceDB: duplicate id '%s' in %s and %s" % [
				t.id, seen[t.id], t.resource_path])
		else:
			seen[t.id] = t.resource_path

	for f in DirAccess.get_files_at("res://Assets/Resources/"):
		if f.ends_with(".tres") and not _is_listed(f):
			push_warning("ResourceDB: %s exists but is not in ALL" % f)


## True if `file_name` (e.g. "ore_1.tres") is one of the resources in ALL.
static func _is_listed(file_name: String) -> bool:
	for t in ALL:
		if t.resource_path.get_file() == file_name:
			return true
	return false


#region resource-dictionary helpers
## These operate on resource dictionaries, not on game state, so they live here
## rather than on the GameManager autoload: a static called through an autoload
## instance warns, and this is where the type they describe already lives.

## Counter dictionaries need a default on every write: `dict[k] += n` errors
## outright when k is absent, and these dictionaries all start empty.
static func add_to(dict: Dictionary, id: StringName, amount: int) -> void:
	dict[id] = dict.get(id, 0) + amount


## Sum of every quantity in a resource dictionary, ignoring which type it is.
static func total_of(dict: Dictionary) -> int:
	var t := 0
	for id in dict:
		t += dict[id]
	return t


## "15 DOLLARS, 2 ORE1" - for tooltips and error messages.
## Takes a cost dictionary, so its keys are ResourceType objects, not ids.
static func format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for t in cost:
		parts.append("%d %s" % [cost[t], t.display_name])
	return ", ".join(parts)
#endregion
