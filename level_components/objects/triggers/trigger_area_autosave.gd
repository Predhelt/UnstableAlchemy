extends Area2D

signal autosaved

## Tracks if this trigger has already called to save the game.
var has_saved : bool = false

func _on_body_entered(body: Node2D) -> void:
	if not has_saved and body == Global.focused_node:
		has_saved = true
		autosaved.emit()
		Global.save_game.call_deferred()

func save(_dir: String) -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"name" : name,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
		"has_saved" : has_saved
	}
	return save_dict
