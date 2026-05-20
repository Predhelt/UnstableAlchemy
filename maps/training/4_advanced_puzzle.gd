extends LevelManager

func _on_trigger_area_cutscene_crystal_end_scene() -> void:
	Global.change_scene("res://maps/main/endings.tscn")
