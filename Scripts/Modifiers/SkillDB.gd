class_name SkillDB

## Money cost to buy one level of an upgrade when a skill does not define its own.
## To change a single upgrade's price, edit its "cost" field below.
## To change the price for every upgrade at once, edit this value.
const DEFAULT_UPGRADE_COST: int = 100

const DATABASE: Dictionary = {
	"center_node" : {
		"name": "Exosuit",
		"description": "Your amazing drilling suit.",
		"max_levels": 1,
		"cost": 0,
		"effects": {}
	},
	"drill_damage": {
		"name": "Drill Power",
		"description": "Increases drill damage per tick.",
		"max_levels": 1,
		"cost": 6,
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
		"max_levels": 5,
		"cost": [10, 15, 22, 32, 45],
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
		"max_levels": 3,
		"cost": [13, 24, 39],
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
		"max_levels": 2,
		"cost": [20, 40],
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
		"max_levels": 1,
		"cost": 5,
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
		"max_levels": 1,
		"cost": 3,
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
		"max_levels": 5,
		"cost": [18, 24, 35, 46, 57],
		"effects": {
			"nodes_on_landing": {
				"type": "ADDITIVE",
				"value": 0.15
			}
		}
	},
	"drop_chance": {
		"name": "Lucky Drilling",
		"description": "Increases chance to generate a drop per drilling tick.",
		"max_levels": 3,
		"cost": 25,
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
		"max_levels": 2,
		"cost": 50,
		"effects": {
			"drops_on_destruction": {
				"type": "ADDITIVE",
				"value": 0.5
			}
		}
	},
	"move_speed": {
		"name": "Thruster Tuning",
		"description": "Increases movement speed.",
		"max_levels": 1,
		"cost": 50,
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
		"max_levels": 5,
		"cost": [8, 13, 18, 23, 28],
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
		"max_levels": 3,
		"cost": 45,
		"effects": {
			"bomb_charges": {
				"type": "FLAT",
				"value": 1.0
			}
		}
	}
}
