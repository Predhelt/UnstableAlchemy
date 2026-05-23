extends PopupMenu


func _on_index_pressed(index: int) -> void:
	if index == 0:
		Global.load_game("user://save")
	elif index == 1:
		Global.load_game("user://autosave")
