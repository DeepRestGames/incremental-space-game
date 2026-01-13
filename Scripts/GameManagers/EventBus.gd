# warnings-disable
extends Node

# Skill tree
@warning_ignore("unused_signal") signal skillNodePressed
@warning_ignore("unused_signal") signal skillNodeExited

# Player movement
@warning_ignore("unused_signal") signal looking_direction_changed(new_looking_direction)
@warning_ignore("unused_signal") signal player_movement(movement_direction)

# Resources
@warning_ignore("unused_signal") signal add_resource(resource_number)
