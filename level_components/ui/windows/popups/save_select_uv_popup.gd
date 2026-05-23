## Changes to the "Level Select" page. Loads only the user variables based on the selected option.
extends PopupMenu

var save_index: int = 0
var autosave_index: int = 1
#var no_save_index: int = 2

func _ready() -> void:
	var has_save_data: bool = false
	var has_autosave_data: bool = false
	if FileAccess.file_exists("savegame.save"):
		has_save_data = true
	if FileAccess.file_exists("autosavegame.save"):
		has_save_data = true
	
	if not has_save_data and not has_autosave_data:
		return
	if not has_save_data:
		remove_item(0)
		save_index = -1
		autosave_index = 0
		#no_save_index = 1
	if not has_autosave_data:
		remove_item(1)
		autosave_index = -1
		#no_save_index = 1

func _on_index_pressed(index: int) -> void:
	if index == save_index: # Manual save data
		Global.load_user_variables("user://save")
	elif index == autosave_index: # Autosave data
		Global.load_user_variables("user://autosave")
	#elif index == no_save_index: # No save data
		#pass
