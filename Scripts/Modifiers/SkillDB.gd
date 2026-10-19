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
		"name": "Impact Drill",
		"description": "A drill and a suit. That's all you have... for now.",
		"cost": [{}],
		"effects": {}
	},
	"drill_damage": {
		"name": "Torque Power",
		"description": "Increases drill damage per tick.",
		"cost": [{ResourceDB.WHITE_CHIP: 6}],
		"effects": {
			"drill_damage_per_tick": {
				"type": "ADDITIVE",
				"value": 0.5
			}
		}
	},
	"drill_damage_2": {
		"name": "That's gonna hurt",
		"description": "Significantly increases drill damage per tick.",
		"cost": [{ResourceDB.WHITE_CHIP: 25}],
		"effects": {
			"drill_damage_per_tick": {
				"type": "ADDITIVE",
				"value": 1
			}
		}
	},
	"drill_speed_1": {
		"name": "Drill Speed",
		"description": "Increases drill attack speed.",
		"cost": [{ResourceDB.WHITE_CHIP: 8}],
		"effects": {
			"drill_attack_speed": {
				"type": "ADDITIVE",
				"value": 0.2
			}
		}
	},
	
	"drill_speed_2": {
		"name": "More Drill Speed",
		"description": "Increases drill attack speed significantly.",
		"cost": [{ResourceDB.WHITE_CHIP: 17}],
		"effects": {
			"drill_attack_speed": {
				"type": "ADDITIVE",
				"value": 0.3
			}
		}
	},
	"drill_crit": {
		"name": "Beginner's Luck",
		"description": "Increases chance of critical damage per tick",
		"cost": [{ResourceDB.WHITE_CHIP: 8}],
		"effects": {
			"drill_crit_chance": {
				"type": "FLAT",
				"value": 0.1
			}
		}
	},
	"drill_crit_2": {
		"name": "Superior Technique",
		"description": "Increases chance of critical damage per tick",
		"cost": [{ResourceDB.WHITE_CHIP: 15}],
		"effects": {
			"drill_crit_chance": {
				"type": "FLAT",
				"value": 0.1
			}
		}
	},
	"drill_crit_damage": {
		"name": "Devastating Criticals",
		"description": "Increases critical damage multiplier.",
		"cost": [{ResourceDB.WHITE_CHIP: 13}, {ResourceDB.WHITE_CHIP: 17}],
		"effects": {
			"drill_crit_damage": {
				"type": "ADDITIVE",
				"value": 1
			}
		}
	},
	"drill_area": {
		"name": "Big Drilling",
		"description": "Increases drill area size.",
		"cost": [{ResourceDB.WHITE_CHIP: 4}],
		"effects": {
			"drill_area_size": {
				"type": "ADDITIVE",
				"value": 0.5
			}
		}
	},
	"drill_area_2": {
		"name": "Big Ass Drill",
		"description": "Significantly increases drill area size.",
		"cost": [{ResourceDB.WHITE_CHIP: 30}],
		"effects": {
			"drill_area_size": {
				"type": "ADDITIVE",
				"value": 1
			}
		}
	},
	"oxygen_capacity": {
		"name": "Oxygen Reserve",
		"description": "Increases oxygen tank capacity.",
		"cost": [{ResourceDB.WHITE_CHIP: 2}],
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
		"cost": [{ResourceDB.WHITE_CHIP: 50}],
		"effects": {
			"nodes_on_landing": {
				"type": "ADDITIVE",
				"value": 0.75
			}
		}
	},
	"chip_chance_unlock": {
		"name": "Chipping tech",
		"description": "Adds chance to find additional while drilling.",
		"cost": [{ResourceDB.WHITE_CHIP: 50}],
		"effects": {
			"drop_chance_per_tick": {
				"type": "FLAT",
				"value": 0.05
			}
		}
	},
	"chip_chance": {
		"name": "Chipping tech",
		"description": "Increases chance to find additional resources while drilling.",
		"cost": [{ResourceDB.WHITE_CHIP: 25}, {ResourceDB.WHITE_CHIP: 25}],
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
		"cost": [{ResourceDB.WHITE_CHIP: 10}],
		"effects": {
			"movement_speed": {
				"type": "ADDITIVE",
				"value": 0.10
			}
		}
	},
	"inventory_capacity": {
		"name": "Big Bag",
		"description": "Increases expedition inventory capacity",
		"cost": [{ResourceDB.WHITE_CHIP: 6}],
		"effects": {
			"inventory_capacity": {
				"type": "FLAT",
				"value": 10.0
			}
		}
	},
	"bomb_unlock": {
		"name": "Geofracturing Device",
		"description": "Unlocks a powerful device which fractures rocks in an area",
		"cost": [{ResourceDB.BLUE_DIAMOND: 1}],
		"effects": {
			"bomb_charges": {
				"type": "FLAT",
				"value": 1.0
			}
		}
	},
	"bomb_charges": {
		"name": "GFD Charges",
		"description": "Increases Geofracturing Device charges.",
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
