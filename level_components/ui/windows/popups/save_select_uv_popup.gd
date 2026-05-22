## Changes to the "Level Select" page. Loads only the user variables based on the selected option.
extends PopupMenu


func _on_index_pressed(index: int) -> void:
	if index == 0: # Manual save data
		Global.load_user_variables("user://save")
		Global.change_scene("res://maps/menu/level_select.tscn")
	elif index == 1: # Autosave data
		Global.load_user_variables("user://autosave")
		Global.change_scene("res://maps/menu/level_select.tscn")
	elif index == 2: # No save data
		Global.change_scene("res://maps/menu/level_select.tscn")
