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
@warning_ignore("unused_signal") signal player_enter_deposit_box_area(deposit_box_position)
@warning_ignore("unused_signal") signal start_resource_transfer_animation_to_deposit_box(resource_number, deposit_box_position)

# Expedition ship
@warning_ignore("unused_signal") signal player_enter_expedition_ship_area
@warning_ignore("unused_signal") signal player_exit_expedition_ship_area

# Expedition
@warning_ignore("unused_signal") signal expedition_started
@warning_ignore("unused_signal") signal expedition_ended

# Capture area
@warning_ignore("unused_signal") signal player_enter_capture_area
@warning_ignore("unused_signal") signal player_exit_capture_area

# HUD
@warning_ignore("unused_signal") signal update_HUD

# Camera
@warning_ignore("unused_signal") signal screen_shake(magnitude: float, decay_rate: float)

# Environment
@warning_ignore("unused_signal") signal breakable_damaged
