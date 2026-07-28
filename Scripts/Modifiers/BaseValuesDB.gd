class_name BaseValuesDB

# Player Stats
const MOVEMENT_SPEED: float = 600.0
const OXYGEN_TANK_CAPACITY: float = 15 # O2 units (= expedition seconds at BASE_OXYGEN_DRAIN_RATE = 1)
const MAX_HP: int = 3
const INVINCIBILITY_COOLDOWN: float = 0.5
const BASE_OXYGEN_DRAIN_RATE: float = 1 # drain rate in O2units / seconds
const BOMB_CHARGES: int = 0

# Player Movement
const ROTATION_SPEED: float = 2
const MINING_SPEED_MULTIPLIER: float = 0.0 # player movement speed while mining; 0 = they can't move while mining

# Starting Inventory Quantities
const STARTING_FABRICATOR_MATERIAL: int = 100
const STARTING_POWERUP_CHIPS: int = 0

# Mining & Drilling Stats
const DRILL_DAMAGE_PER_TICK: float = 10.0
const DRILL_CRIT_CHANCE: float = 0.0
const DRILL_CRIT_DAMAGE: float = 1.5
const DRILL_AREA_SIZE: float = 20.0
const DRILL_ATTACK_SPEED: float = 1

# Breakable / Resource Nodes Stats
const RESOURCE_SPAWN_CHANCE_ON_DAMAGED: float = 0
const MIN_RESOURCE_NUMBER: int = 1
const MAX_RESOURCE_NUMBER: int = 2
