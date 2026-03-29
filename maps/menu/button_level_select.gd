class_name LevelSelectButton extends Button

@export_file var level_path


func _on_pressed() -> void:
	Global.change_scene(level_path)
