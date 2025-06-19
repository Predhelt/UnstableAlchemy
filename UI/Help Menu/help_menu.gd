extends Panel


func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode == &"help":
		global.mode = &"default"
		visible = false

func open_window() -> void:
	if global.mode == &"default":
			global.mode = &"help"
			%WindowName.text = "Help"
			visible = true

func _on_button_close_pressed() -> void:
	close_window()
