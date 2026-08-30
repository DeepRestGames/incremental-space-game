# warnings-disable
extends Node

# Globals
@warning_ignore("unused_signal") signal on_player_ready(player_reference)

# Inputs
@warning_ignore("unused_signal") signal action_trigger_interact
@warning_ignore("unused_signal") signal player_movement(movement_direction)

# Skill tree
## Emitted whenever skill levels change and the stat cache has been rebuilt.
## Anything that caches a value derived from SkillModifiers must listen to this.
@warning_ignore("unused_signal") signal stats_changed

# Expedition ship
@warning_ignore("unused_signal") signal player_enter_expedition_ship_area
@warning_ignore("unused_signal") signal player_exit_expedition_ship_area
@warning_ignore("unused_signal") signal player_enter_expedition_return_area
@warning_ignore("unused_signal") signal player_exit_expedition_return_area

# Skill tree terminal
@warning_ignore("unused_signal") signal player_enter_skill_terminal_area
@warning_ignore("unused_signal") signal player_exit_skill_terminal_area

# Shop
@warning_ignore("unused_signal") signal player_enter_shop_area
@warning_ignore("unused_signal") signal player_exit_shop_area

# Expedition
@warning_ignore("unused_signal") signal expedition_started

# HUD
@warning_ignore("unused_signal") signal update_HUD
@warning_ignore("unused_signal") signal update_oxygen_HUD(current, max_val)
@warning_ignore("unused_signal") signal update_bomb_HUD(current, max_val)
## Emitted by the Player but not displayed yet: there is no HP counter in the HUD.
@warning_ignore("unused_signal") signal update_current_hp_HUD(hp_amount)

# UI state
## Emitted whenever a full-screen UI opens or closes. Anything whose visibility
## depends on "is a menu covering the world" listens here and re-derives.
@warning_ignore("unused_signal") signal ui_state_changed

# Environment
@warning_ignore("unused_signal") signal breakable_damaged(damage_value: int, is_crit: bool)
