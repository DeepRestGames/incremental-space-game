class_name SkillDB

## Money cost to buy one level of an upgrade when a skill does not define its own.
## To change a single upgrade's price, edit its "cost" field below.
## To change the price for every upgrade at once, edit this value.
const DEFAULT_UPGRADE_COST: int = 100

const DATABASE: Dictionary = {
	"center_node" : {
		"name": "Exosuit",
		"description": "Your amazing drilling suit.",
		"cost": [0],
		"effects": {}
	},
	"drill_damage": {
		"name": "Drill Power",
		"description": "Increases drill damage per tick.",
		"cost": [6],
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
		"cost": [5],
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
		"cost": [3],
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
		"cost": [25, 25, 25],
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
		"cost": [50, 50],
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
		"cost": [50],
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
		"cost": [45, 45, 45],
		"effects": {
			"bomb_charges": {
				"type": "FLAT",
				"value": 1.0
			}
		}
	}
}
