extends Panel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options_menu"):
		toggle_window()
	if event.is_action_pressed("ui_cancel"):
		match global.mode:
			#&"default" : open_window()
			&"options" : close_window()

func toggle_window():
	if visible:
		close_window()
	else:
		open_window()

func open_window():
	if global.mode == &"default": 
			global.mode = &"options"
			visible = true

func close_window():
	if global.mode == &"options":
		global.mode = &"default"
		visible = false

func _on_button_return_pressed() -> void:
	close_window()

func _on_button_settings_pressed() -> void:
	%SettingsMenu.popup()
	close_window()

func _on_button_exit_pressed() -> void:
	get_tree().quit()
