class_name SkillDB

const DATABASE: Dictionary = {
	"center_node" : {
		"name": "Exosuit",
		"description": "Your amazing drilling suit.",
		"max_levels": 1,
		"effects": {}
	},
	"drill_damage": {
		"name": "Drill Power",
		"description": "Increases drill damage per tick.",
		"max_levels": 5,
		"effects": { "drill_damage_per_tick": 1.0 }
	},
	"drill_speed": {
		"name": "Drill Speed",
		"description": "Increases drill attack speed.",
		"max_levels": 5,
		"effects": { "drill_attack_speed": 0.15 }
	},
	"drill_crit": {
		"name": "Lucky Strike",
		"description": "Increases drill crit chance.",
		"max_levels": 5,
		"effects": { "drill_crit_chance": 0.05 }
	},
	"drill_crit_damage": {
		"name": "Crushing Blows",
		"description": "Increases drill crit damage.",
		"max_levels": 5,
		"effects": { "drill_crit_damage": 0.5 }
	},
	"drill_area": {
		"name": "Wide Reaches",
		"description": "Increases drill area size.",
		"max_levels": 5,
		"effects": { "drill_area_size": 10.0 }
	},
	"oxygen_capacity": {
		"name": "Oxygen Reserve",
		"description": "Increases oxygen tank capacity.",
		"max_levels": 5,
		"effects": { "oxygen_tank_capacity": 20.0 }
	},
	"nodes_landing": {
		"name": "Node Locator",
		"description": "Increases nodes found on landing.",
		"max_levels": 5,
		"effects": { "nodes_on_landing": 0.1 }
	},
	"drop_chance": {
		"name": "Lucky Drilling",
		"description": "Increases chance to generate a drop per drilling tick.",
		"max_levels": 5,
		"effects": { "drop_chance_per_tick": 0.05 }
	},
	"destroy_drops": {
		"name": "Asteroid Shatterer",
		"description": "Increases drops generated when a node is destroyed.",
		"max_levels": 5,
		"effects": { "drops_on_destruction": 2.0 }
	},
	"move_speed": {
		"name": "Thruster Tuning",
		"description": "Increases movement speed.",
		"max_levels": 5,
		"effects": { "movement_speed": 50.0 }
	},
	"bomb_charges": {
		"name": "Bomb Payload",
		"description": "Increases number of bomb charges.",
		"max_levels": 5,
		"effects": { "bomb_charges": 1.0 }
	}
}
