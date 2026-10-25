class_name ResourceType
extends Resource

# Question: what's the id for? what is the &?
@export var id: StringName                  # &"titanium"
@export var display_name: String            # "Titanium"
@export var icon: Texture2D
## Shown in tooltips, e.g. "Raw material. Only valuable if processed."
@export_multiline var description: String
