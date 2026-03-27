extends Area2D


@export_dir var level_path : String

#func _ready() -> void:
	#level_path = level_path.replace('.remap','')

## When player enters the area, load the level being stored.
func _on_body_entered(_body: Node2D) -> void:
	#call_deferred()
	#TODO: Transfer any data that is relevant between levels.
	#(inventory, known_recipes, crafted_recipes, etc.)
	if level_path:
		Global.change_scene(level_path)
	else:
		print("ERROR: No level path set for scene change.")
