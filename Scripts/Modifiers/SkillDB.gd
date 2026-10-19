class_name SkillDB

## Money cost to buy one level of an upgrade when a skill does not define its own.
## To change a single upgrade's price, edit its "cost" field below.
## To change the price for every upgrade at once, edit this value.
const DEFAULT_UPGRADE_COST: int = 100
const DEFAULT_CURRENCY := ResourceDB.WHITE_CHIP

#region usable for skill tree
static var _used_ids: Dictionary[StringName, bool] = {}

## True if at least one skill, at any rank, costs this resource. 
static func uses_resource(id: StringName) -> bool:
	if _used_ids.is_empty():
		for skill_id in DATABASE:
			for rank_cost in DATABASE[skill_id].get("cost", []):
				for t in rank_cost:
					_used_ids[t.id] = true
	return _used_ids.has(id)
#endregion



const DATABASE: Dictionary = {
	"center_node": {
		"name": "Exosuit",
		"description": "Your amazing drilling suit.",
		"cost": [{}],
		"effects": {}
	},
	"drill_damage": {
		"name": "Drill Power",
		"description": "Increases drill damage per tick.",
		"cost": [{ResourceDB.WHITE_CHIP: 6}],
		"effects": {
			"drill_damage_per_tick": {
				"type": "ADDITIVE",
				"value": 0.5
			}
		}
	},
	"drill_speed": {
		"name": "Drill Speed",
		"description": "Increases drill attack speed.",
		"cost": [{ResourceDB.WHITE_CHIP: 10}, {ResourceDB.WHITE_CHIP: 15}, {ResourceDB.WHITE_CHIP: 22}, {ResourceDB.WHITE_CHIP: 32},
			{ResourceDB.WHITE_CHIP: 45}],
		"effects": {
			"drill_attack_speed": {
				"type": "ADDITIVE",
				"value": 0.1
			}
		}
	},
	"drill_crit": {
		"name": "Lucky Strike",
		"description": "Increases chance of critical drilling damage",
		"cost": [{ResourceDB.WHITE_CHIP: 13}, {ResourceDB.WHITE_CHIP: 24}, {ResourceDB.WHITE_CHIP: 39}],
		"effects": {
			"drill_crit_chance": {
				"type": "FLAT",
				"value": 0.07
			}
		}
	},
	"drill_crit_damage": {
		"name": "Crushing Blows",
		"description": "Increases drill crit damage.",
		"cost": [{ResourceDB.WHITE_CHIP: 20}, {ResourceDB.WHITE_CHIP: 40}],
		"effects": {
			"drill_crit_damage": {
				"type": "ADDITIVE",
				"value": 0.5
			}
		}
	},
	"drill_area": {
		"name": "Wide Reaches",
		"description": "Increases drill area size.",
		"cost": [{ResourceDB.WHITE_CHIP: 5}],
		"effects": {
			"drill_area_size": {
				"type": "ADDITIVE",
				"value": .5
			}
		}
	},
	"oxygen_capacity": {
		"name": "Oxygen Reserve",
		"description": "Increases oxygen tank capacity.",
		"cost": [{ResourceDB.WHITE_CHIP: 3}],
		"effects": {
			"oxygen_tank_capacity": {
				"type": "ADDITIVE",
				"value": 0.15
			}
		}
	},
	"oxygen_capacity_2": {
		"name": "Bigger Oxygen Reserve",
		"description": "Increases oxygen tank capacity.",
		"cost": [{ResourceDB.WHITE_CHIP: 25}],
		"effects": {
			"oxygen_tank_capacity": {
				"type": "ADDITIVE",
				"value": 0.15
			}
		}
	},
	"nodes_landing": {
		"name": "Node Locator",
		"description": "Increases nodes found on landing.",
		"cost": [{ResourceDB.WHITE_CHIP: 20}],
		"effects": {
			"nodes_on_landing": {
				"type": "ADDITIVE",
				"value": 0.75
			}
		}
	},
	"drop_chance": {
		"name": "Lucky Drilling",
		"description": "Increases chance to generate a drop per drilling tick.",
		"cost": [{ResourceDB.WHITE_CHIP: 25}, {ResourceDB.WHITE_CHIP: 25}, {ResourceDB.WHITE_CHIP: 25}],
		"effects": {
			"drop_chance_per_tick": {
				"type": "FLAT",
				"value": 0.05
			}
		}
	},
	"destroy_drops": {
		"name": "Precise Drilling",
		"description": "Increases drops generated when a node is destroyed.",
		"cost": [{ResourceDB.WHITE_CHIP: 50}, {ResourceDB.WHITE_CHIP: 50}],
		"effects": {
			"drops_on_destruction": {
				"type": "FLAT",
				"value": 1
			}
		}
	},
	"move_speed": {
		"name": "Thruster Tuning",
		"description": "Increases movement speed.",
		"cost": [{ResourceDB.WHITE_CHIP: 50}],
		"effects": {
			"movement_speed": {
				"type": "ADDITIVE",
				"value": 0.10
			}
		}
	},
	"inventory_capacity": {
		"name": "Bigger Backpack",
		"description": "Increases how many resources you can carry.",
		"cost": [{ResourceDB.WHITE_CHIP: 8}, {ResourceDB.WHITE_CHIP: 13}, {ResourceDB.WHITE_CHIP: 18}, {ResourceDB.WHITE_CHIP: 23},
			{ResourceDB.WHITE_CHIP: 28}],
		"effects": {
			"inventory_capacity": {
				"type": "FLAT",
				"value": 5.0
			}
		}
	},
	"bomb_charges": {
		"name": "Bomb Payload",
		"description": "Increases number of bomb charges.",
		"cost": [{ResourceDB.WHITE_CHIP: 45}, {ResourceDB.WHITE_CHIP: 45}, {ResourceDB.WHITE_CHIP: 45}],
		"effects": {
			"bomb_charges": {
				"type": "FLAT",
				"value": 1.0
			}
		}
	},
	#"XXX": {
	#"name": "XXX Box",
	#"description": "Keep more of your cargo when an expedition fails.",
	#"cost": [ {ResourceDB.WHITE_CHIP: 40}, {ResourceDB.WHITE_CHIP: 80} ],
	#"effects": {
	#"failure_keep_ratio": {"type": "ADDITIVE", "value": 0.25}
	#}
	#},
}
