extends Panel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options_menu"):
		toggle_menu()
	if event.is_action_pressed("ui_cancel"):
		match global.mode:
			"default" : open_menu()
			"options" : close_menu()

func toggle_menu():
	if visible:
		close_menu()
	else:
		open_menu()

func open_menu():
	global.mode = "options"
	visible = true

func close_menu():
	global.mode = "default"
	visible = false

func _on_button_return_pressed() -> void:
	close_menu()

func _on_button_settings_pressed() -> void:
	%SettingsMenu.popup()
	close_menu()

func _on_button_exit_pressed() -> void:
	get_tree().quit()
