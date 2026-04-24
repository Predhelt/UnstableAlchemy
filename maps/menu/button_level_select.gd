class_name LevelSelectButton extends Button

@export_file var level_path


func _on_pressed() -> void:
	$AudioStreamPlayer2D.play()
	Global.change_scene(level_path)
