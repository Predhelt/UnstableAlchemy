extends Area2D

## File path of the level to be loaded.
@export_file var level_path

@export var is_level_cleared: bool = false

#func _ready() -> void:
	#level_path = level_path.replace('.remap','')

## When player enters the area, load the level being stored.
func _on_body_entered(_body: Node2D) -> void:
	#call_deferred()
	#TODO: Transfer any data that is relevant between levels.
	#(inventory, known_recipes, crafted_recipes, etc.)
	if level_path:
		if is_level_cleared:
			get_tree().current_scene.level_cleared()
		get_tree().current_scene.change_level_and_fade(level_path)
	else:
		print("ERROR: No level path set for scene change.")
