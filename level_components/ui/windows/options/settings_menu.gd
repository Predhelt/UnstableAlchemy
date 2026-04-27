extends Window

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_requested()


func _on_close_requested() -> void:
	Global.mode = &"default"
	hide()


func _on_about_to_popup() -> void:
	Global.mode = &"settings"
