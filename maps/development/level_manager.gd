class_name LevelManager extends Node2D

@export var level_index: int = 0

func _ready() -> void:
	Global.current_level_path = scene_file_path

## Called when the level is cleared. Updates relevant progression variables.
func level_cleared() -> void:
	if level_index > UserVariables.level_highest_cleared_index:
		UserVariables.level_highest_cleared_index = level_index
