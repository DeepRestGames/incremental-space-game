# warnings-disable
extends Node

# Inputs
@warning_ignore("unused_signal") signal action_trigger_interact
@warning_ignore("unused_signal") signal player_movement(movement_direction)
@warning_ignore("unused_signal") signal looking_direction_changed(new_looking_direction)

# Skill tree
@warning_ignore("unused_signal") signal skillNodePressed
@warning_ignore("unused_signal") signal skillNodeExited

# Resources
@warning_ignore("unused_signal") signal add_resource(resource_number)

# Deposit box
@warning_ignore("unused_signal") signal player_enter_deposit_box_area

# Expedition ship
@warning_ignore("unused_signal") signal player_enter_expedition_ship_area
@warning_ignore("unused_signal") signal player_exit_expedition_ship_area

# Expedition
@warning_ignore("unused_signal") signal expedition_started
@warning_ignore("unused_signal") signal expedition_ended
