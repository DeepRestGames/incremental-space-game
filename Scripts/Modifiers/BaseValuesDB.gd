class_name BaseValuesDB

# Player Stats
const MOVEMENT_SPEED: float = 600.0
const OXYGEN_TANK_CAPACITY: float = 15 # O2 units (= expedition seconds at BASE_OXYGEN_DRAIN_RATE = 1)
const MAX_HP: int = 3
const INVINCIBILITY_COOLDOWN: float = 0.5
const BASE_OXYGEN_DRAIN_RATE: float = 1 # drain rate in O2units / seconds#

const BOMB_CHARGES: int = 0
const BOMB_DAMAGE: float = 30.0
# Seconds of grace at the start of an expedition, before oxygen starts draining.
# The player is free to move during it; it exists to let them get their bearings.
# Sized to outlast the intro animation (~3.0s) with a beat of clean screen after it.
const EXPEDITION_GRACE_PERIOD: float = 3.5

# Player Movement
const MINING_SPEED_MULTIPLIER: float = 0.0 # player movement speed while mining; 0 = they can't move while mining

# Starting Inventory Quantities
const STARTING_FABRICATOR_MATERIAL: int = 100
const STARTING_POWERUP_CHIPS: int = 0
const INVENTORY_CAPACITY: int = 8 # max resources the player can carry in one expedition

# Mining & Drilling Stats
const DRILL_DAMAGE_PER_TICK: float = 10.0
const DRILL_CRIT_CHANCE: float = 0.0 # RATIO! [0,1]
const DRILL_CRIT_DAMAGE: float = 1.5
const DRILL_AREA_SIZE: float = 20.0
const DRILL_ATTACK_SPEED: float = 1

# Breakable / Resource Nodes Stats
const RESOURCE_SPAWN_CHANCE_ON_DAMAGED: float = 0
const MIN_RESOURCE_NUMBER: int = 1
const MAX_RESOURCE_NUMBER: int = 2


## Registry of every stat that skills are allowed to modify: stat id -> base value.
## This is the single list of "modifiable stats" in the game: SkillModifiers builds
## its cache from these keys, so a skill in SkillDB pointing at a stat that is not
## listed here is reported as an error instead of silently doing nothing.
##
## To add a new upgradable stat: add the base value above, add it to this map, then
## read it through a SkillModifiers getter. Adding it here alone is not enough -
## something has to actually read it.
const BASE_VALUES: Dictionary = {
	"movement_speed": MOVEMENT_SPEED,
	"oxygen_tank_capacity": OXYGEN_TANK_CAPACITY,
	"bomb_charges": BOMB_CHARGES,
	"bomb_damage": BOMB_DAMAGE,
	"inventory_capacity": INVENTORY_CAPACITY,
	"drill_damage_per_tick": DRILL_DAMAGE_PER_TICK,
	"drill_crit_chance": DRILL_CRIT_CHANCE,
	"drill_crit_damage": DRILL_CRIT_DAMAGE,
	"drill_area_size": DRILL_AREA_SIZE,
	"drill_attack_speed": DRILL_ATTACK_SPEED,
	"drop_chance_per_tick": RESOURCE_SPAWN_CHANCE_ON_DAMAGED,
	"nodes_on_landing": 0.0,
	"drops_on_destruction": 0.0,
}
