extends LevelManager

var mysterious_crystal : Item = preload("res://game_systems/items/gatherable/mysterious_crystal.tres")


func setup_level():
	Global.mode = &"default"
	EventHandler.open_popup_message(
		"This is the final puzzle of the demo.
		This represents one of the later puzzles.
		Check your inventory and use what you know to proceed.
		Don't forget to reset if you get stuck.
		Good luck!"
		)


func add_crystal_to_gathered_items(node : Node) -> void:
	var entry = ["world", "grab"]
	if node.gathered_items.keys().is_empty() or mysterious_crystal.id not in node.gathered_items.keys():
		node.gathered_items[mysterious_crystal.id] = {entry : 1}
		if mysterious_crystal.type == "Book":
			return
		if "is_camera_focused" not in node: # Implied that UserVariables is being updated if is_camera_focused is not a variable in the node.
			Global.emit_notification("Log Book Entry Added")
	elif entry not in node.gathered_items[mysterious_crystal.id].keys():
		node.gathered_items[mysterious_crystal.id][entry] = 1
	else:
		node.gathered_items[mysterious_crystal.id][entry] += 1

func _on_trigger_area_cutscene_crystal_end_scene() -> void:
	add_crystal_to_gathered_items($Player)
	add_crystal_to_gathered_items(UserVariables)
	level_cleared()
	change_level_and_fade("res://maps/training/endings.tscn")


func _on_trigger_area_autosave_4_autosaved() -> void:
	$TutorialTim.has_player_solved = true
