extends Area2D

## Tracks if this trigger has already called to save the game.
#var has_saved : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body == Global.focused_node:
		Global.save_game("user://autosave")
		queue_free()
