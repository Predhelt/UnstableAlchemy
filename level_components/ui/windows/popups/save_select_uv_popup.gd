## Changes to the "Level Select" page. Loads only the user variables based on the selected option.
extends PopupMenu

var save_index: int = -1
var autosave_index: int = -1
#var no_save_index: int = 2


func _on_index_pressed(index: int) -> void:
	if index == save_index: # Manual save data
		Global.load_user_variables("user://saves/save")
	elif index == autosave_index: # Autosave data
		Global.load_user_variables("user://saves/autosave")
	#elif index == no_save_index: # No save data
		#pass


func _on_visibility_changed() -> void:
	var has_save_data: bool = FileAccess.file_exists("user://saves/savegame.save")
	var has_autosave_data: bool = FileAccess.file_exists("user://saves/autosavegame.save")
	
	clear()
	save_index = -1
	autosave_index = -1
	
	if has_save_data:
		add_item("Load data from Save")
		save_index = 0
	if has_autosave_data:
		add_item("Load data from Autosave")
		if save_index == 0:
			autosave_index = 1
		else:
			autosave_index = 0
	if not has_save_data and not has_autosave_data:
		Global.emit_notification("No save data found.")
		hide()
		return
	add_item("Do not load save data")
