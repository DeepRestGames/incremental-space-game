class_name SkillModifiers

## Central stat engine.
##
## Every skill effect in SkillDB is folded into a small cache exactly once, by
## rebuild(). The only caller of rebuild() is GameManager._on_skills_changed(),
## which runs whenever skill levels change for any reason (buy, refund, reset,
## load from save).
##
## Reading a stat afterwards is a dictionary lookup plus three multiplications,
## so gameplay code can safely read stats every frame - nothing iterates over
## the skill tree at read time.
##
## The cache lives in static vars, which belong to the script rather than to any
## node, so it survives scene changes untouched.

## stat id -> {"flat": float, "additive": float, "mult": float}
## Only stats that at least one owned skill modifies appear here.
static var _mods: Dictionary = {}

## stat id -> final value, computed from the global base in BaseValuesDB.BASE_VALUES
static var _values: Dictionary = {}


## Recomputes the whole cache from the given skill levels.
## This is the ONLY function in the project that iterates over skills.
static func rebuild(skill_levels: Dictionary, database: Dictionary = SkillDB.DATABASE) -> void:
	_mods.clear()
	_values.clear()

	for skill_id in skill_levels:
		# int() rather than a typed read: JSON save files hand back floats.
		var rank: int = int(skill_levels[skill_id])
		if rank <= 0:
			continue

		var effects: Dictionary = database.get(skill_id, {}).get("effects", {})
		for stat_id in effects:
			if not BaseValuesDB.BASE_VALUES.has(stat_id):
				push_error("SkillDB: skill '%s' modifies unknown stat '%s'. Add it to BaseValuesDB.BASE_VALUES." % [skill_id, stat_id])
				continue

			var acc: Dictionary = _mods.get(stat_id, {"flat": 0.0, "additive": 0.0, "mult": 1.0})
			var effect = effects[stat_id]

			if effect is Dictionary:
				var value: float = effect.get("value", 0.0)
				match effect.get("type", "FLAT"):
					"FLAT":
						acc["flat"] += rank * value
					"ADDITIVE":
						acc["additive"] += rank * value
					"MULTIPLICATIVE":
						acc["mult"] *= 1.0 + value * pow(1.2, rank - 1)
					var unknown_type:
						push_error("SkillDB: skill '%s' uses unknown effect type '%s'." % [skill_id, unknown_type])
			else:
				# Fallback for the old plain-float effect format
				acc["flat"] += rank * float(effect)

			_mods[stat_id] = acc

	for stat_id in BaseValuesDB.BASE_VALUES:
		_values[stat_id] = get_modified_stat(stat_id, BaseValuesDB.BASE_VALUES[stat_id])


## Applies the cached skill modifiers to an arbitrary base value.
## Use this when the base is per-instance rather than global - for example a
## Breakable's own resource_spawn_chance_on_damaged.
static func get_modified_stat(stat_id: String, base_value: float) -> float:
	var acc = _mods.get(stat_id)
	if acc == null:
		# No owned skill touches this stat: the base value is already the answer.
		return base_value
	return (base_value + acc["flat"]) * (1.0 + acc["additive"]) * acc["mult"]


## Returns a stat computed from its global base value in BaseValuesDB.
static func get_stat(stat_id: String) -> float:
	if _values.has(stat_id):
		return _values[stat_id]
	if BaseValuesDB.BASE_VALUES.has(stat_id):
		# rebuild() has not run yet, so no skill can have been bought either.
		return BaseValuesDB.BASE_VALUES[stat_id]
	push_error("SkillModifiers: unknown stat '%s'. Add it to BaseValuesDB.BASE_VALUES." % stat_id)
	return 0.0


# Typed accessors - the API the rest of the game uses.
# They keep the stat id strings confined to this file and to SkillDB, so a typo
# elsewhere is a compile error instead of a silently ignored upgrade.

static func get_movement_speed() -> float:
	return get_stat("movement_speed")


static func get_oxygen_tank_capacity() -> float:
	return get_stat("oxygen_tank_capacity")


static func get_bomb_charges() -> int:
	return int(get_stat("bomb_charges"))


static func get_inventory_capacity() -> int:
	return int(get_stat("inventory_capacity"))


static func get_drill_damage_per_tick() -> float:
	return get_stat("drill_damage_per_tick")


static func get_drill_attack_speed() -> float:
	return get_stat("drill_attack_speed")


static func get_drill_crit_chance() -> float:
	return get_stat("drill_crit_chance")


static func get_drill_crit_damage() -> float:
	return get_stat("drill_crit_damage")


static func get_nodes_on_landing() -> float:
	return get_stat("nodes_on_landing")


static func get_drops_on_destruction() -> float:
	return get_stat("drops_on_destruction")


# These two take a base value because their callers own it per-instance.

static func get_drill_area_size(base_value: float = BaseValuesDB.DRILL_AREA_SIZE) -> float:
	return get_modified_stat("drill_area_size", base_value)


static func get_drop_chance_per_tick(base_value: float = BaseValuesDB.RESOURCE_SPAWN_CHANCE_ON_DAMAGED) -> float:
	return get_modified_stat("drop_chance_per_tick", base_value)
