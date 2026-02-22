extends Button

@export_file var level_path


func _on_pressed() -> void:
	if level_path == null:
		return
	global.mode = &"default"
	get_tree().change_scene_to_file(level_path)
