class_name SkillModifiers

# Generic modifier calculators

static func get_stat_modifier(stat_name: String) -> float:
	var gm = Engine.get_main_loop().root.get_node_or_null("GameManager")
	if not gm:
		return 0.0
		
	var flat_sum := 0.0
	var additive_percent_sum := 0.0
	for skill_id in gm.skill_levels:
		var rank = gm.skill_levels[skill_id]
		if rank <= 0:
			continue
		var skill_info = gm.skill_db.get(skill_id, {})
		var effects = skill_info.get("effects", {})
		if stat_name in effects:
			var effect = effects[stat_name]
			if effect is Dictionary:
				var type = effect.get("type", "FLAT")
				var val = effect.get("value", 0.0)
				match type:
					"FLAT":
						flat_sum += rank * val
					"ADDITIVE":
						additive_percent_sum += rank * val
			else:
				flat_sum += rank * float(effect)
	return flat_sum + additive_percent_sum


static func get_modified_stat(stat_name: String, base_value: float) -> float:
	var gm = Engine.get_main_loop().root.get_node_or_null("GameManager")
	if not gm:
		return base_value
		
	var flat_sum := 0.0
	var additive_percent_sum := 0.0
	var multiplicative_product := 1.0
	
	for skill_id in gm.skill_levels:
		var rank = gm.skill_levels[skill_id]
		if rank <= 0:
			continue
			
		var skill_info = gm.skill_db.get(skill_id, {})
		var effects = skill_info.get("effects", {})
		if stat_name in effects:
			var effect = effects[stat_name]
			if effect is Dictionary:
				var type = effect.get("type", "FLAT")
				var val = effect.get("value", 0.0)
				
				match type:
					"FLAT":
						flat_sum += rank * val
					"ADDITIVE":
						additive_percent_sum += rank * val
					"MULTIPLICATIVE":
						var pct = val * pow(1.2, rank - 1)
						multiplicative_product *= (1.0 + pct)
			else:
				# Fallback for old simple float structure if any remains
				flat_sum += rank * float(effect)
				
	var value = base_value + flat_sum
	var additive = value * additive_percent_sum
	return (value + additive) * multiplicative_product


# Centralized helper functions for all stats in SkillDB:

static func get_movement_speed(base_value: float = BaseValuesDB.MOVEMENT_SPEED) -> float:
	return get_modified_stat("movement_speed", base_value)


static func get_oxygen_tank_capacity(base_value: float = BaseValuesDB.OXYGEN_TANK_CAPACITY) -> float:
	return get_modified_stat("oxygen_tank_capacity", base_value)


static func get_bomb_charges(base_value: float = BaseValuesDB.BOMB_CHARGES) -> float:
	return get_modified_stat("bomb_charges", base_value)


static func get_drill_damage_per_tick(base_value: float = BaseValuesDB.DRILL_DAMAGE_PER_TICK) -> float:
	return get_modified_stat("drill_damage_per_tick", base_value)


static func get_drill_attack_speed(base_value: float = BaseValuesDB.DRILL_ATTACK_SPEED) -> float:
	return get_modified_stat("drill_attack_speed", base_value)


static func get_drill_crit_chance(base_value: float = BaseValuesDB.DRILL_CRIT_CHANCE) -> float:
	return get_modified_stat("drill_crit_chance", base_value)


static func get_drill_crit_damage(base_value: float = BaseValuesDB.DRILL_CRIT_DAMAGE) -> float:
	return get_modified_stat("drill_crit_damage", base_value)


static func get_drill_area_size(base_value: float = BaseValuesDB.DRILL_AREA_SIZE) -> float:
	return get_modified_stat("drill_area_size", base_value)


static func get_nodes_on_landing(base_value: float = 0.0) -> float:
	return get_modified_stat("nodes_on_landing", base_value)


static func get_drop_chance_per_tick(base_value: float = BaseValuesDB.RESOURCE_SPAWN_CHANCE_ON_DAMAGED) -> float:
	return get_modified_stat("drop_chance_per_tick", base_value)


static func get_drops_on_destruction(base_value: float = 0.0) -> float:
	return get_modified_stat("drops_on_destruction", base_value)
