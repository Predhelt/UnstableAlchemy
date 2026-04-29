class_name LevelSelectButton extends Button

## File path of the level to be loaded.
@export_file var level_path


func _on_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	Global.change_scene(level_path)


func _on_entered() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"
