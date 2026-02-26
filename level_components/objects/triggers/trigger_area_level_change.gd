extends Area2D


@export_dir var level_path : String

## When player enters the area, load the level being stored.
func _on_body_entered(_body: Node2D) -> void:
	#call_deferred()
	#TODO: Transfer any data that is relevant between levels.
	#(inventory, known_recipes, crafted_recipes, etc.)
	change_scene()

func change_scene() -> void:
	global.save_persistent_characters()
	get_tree().change_scene_to_file(level_path)
