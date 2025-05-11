extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_alchemy"):
		toggle_activity() # Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		close_activity()

func toggle_activity() -> void:
	visible = !visible # Flip visibility of the inventory

func close_activity() -> void:
	visible = false
