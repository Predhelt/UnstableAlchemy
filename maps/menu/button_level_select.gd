class_name LevelSelectButton extends Button

@export_file var level_path


func _on_pressed() -> void:
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D["parameters/switch_to_clip"] = "press"
	Global.change_scene(level_path)


func _on_entered() -> void:
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D["parameters/switch_to_clip"] = "hover"
