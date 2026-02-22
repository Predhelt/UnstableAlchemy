extends Button

@export_file var menu_path


func _on_pressed() -> void:
	if menu_path == null:
		return
	get_tree().change_scene_to_file(menu_path)
