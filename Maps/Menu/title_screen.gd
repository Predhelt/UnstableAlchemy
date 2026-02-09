extends Control

#@export var levels

## Opens the level that was selected. Returns whether or not the level was opened successfuly.
func open_level() -> bool:
	return false

func _on_button_play_pressed() -> void:
	pass


func _on_button_settings_pressed() -> void:
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit()
