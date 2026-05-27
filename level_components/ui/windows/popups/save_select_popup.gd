extends PopupMenu

var save_index: int = -1
var autosave_index: int = -1

func _on_index_pressed(index: int) -> void:
	if index == save_index:
		Global.load_game("save")
	elif index == autosave_index:
		Global.load_game("autosave")


func _on_visibility_changed() -> void:
	if not visible:
		return
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
