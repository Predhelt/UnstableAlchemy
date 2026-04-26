extends Button

@export_file var menu_path


func _on_pressed() -> void:
	if menu_path == null:
		return
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D["parameters/switch_to_clip"] = "press"
	get_tree().change_scene_to_file(menu_path)


func _on_entered() -> void:
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D["parameters/switch_to_clip"] = "hover"
