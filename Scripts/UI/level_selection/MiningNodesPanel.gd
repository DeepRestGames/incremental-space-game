class_name MiningNodesPanel
extends PanelContainer

## "Mining Nodes": one card per rock the planet spawns. The data comes from
## LevelPreview; this panel only draws it.

const ROCK_CARD := preload("res://Scenes/UI/level_selection/RockCard.tscn")


func show_level(level: LevelData) -> void:
	for child in %Cards.get_children():
		%Cards.remove_child(child)
		child.queue_free()
	for rock in LevelPreview.read(level)["rocks"]:
		var card: RockCard = ROCK_CARD.instantiate()
		%Cards.add_child(card)
		card.setup(rock)
