class_name ResourceDB

const MONEY1 := preload("res://GameResources/money_1.tres")
const MONEY2 := preload("res://GameResources/money_2.tres")
const ORE1 := preload("res://GameResources/ore_1.tres")
const ORE2 := preload("res://GameResources/ore_2.tres")
const REFINED1 := preload("res://GameResources/refined_1.tres")
const REFINED2 := preload("res://GameResources/refined_2.tres")
#Materials
const WHITE_TRIANGLE = preload("uid://4xra85surmlh")
const WHITE_SQUARE = preload("uid://cag2bw6x17n46")
const BLUE_DIAMOND = preload("uid://d1r5ngv5sjq48")
#Currencies
const WHITE_CHIP = preload("uid://2q7gnpjkf8pp")
const WHITE_STACK = preload("uid://8wmsviqcnic8")
const WHITE_BOX = preload("uid://brf3wf1qbvkk3")
const WHITE_BLOCK = preload("uid://5pbr7w37g0y4")

const RESOURCE_ROOT := "res://GameResources/"

# NOTE: questo può essere usato per definire l'ordine di display or smth
const ALL: Array[ResourceType] = [WHITE_CHIP, WHITE_STACK, WHITE_BOX, WHITE_BLOCK,
BLUE_DIAMOND, WHITE_SQUARE, WHITE_TRIANGLE, 
MONEY1, MONEY2, ORE1, ORE2, REFINED1, REFINED2]

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

	_warn_unlisted(RESOURCE_ROOT)
	
## Walks the folder tree and warns about any ResourceType on disk that isn't in
## ALL. Compares the loaded object, not the file name, so a recipe that shares a
## file name with a resource can neither hide nor fake a match.
static func _warn_unlisted(dir: String) -> void:
	for sub in DirAccess.get_directories_at(dir):
		_warn_unlisted(dir.path_join(sub))
	for f in DirAccess.get_files_at(dir):
		if not f.ends_with(".tres"):
			continue
		var res := load(dir.path_join(f))
		if res is ResourceType and not ALL.has(res):
			push_warning("ResourceDB: %s is not in ALL" % dir.path_join(f))



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
