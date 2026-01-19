extends Panel

## Keeps track of what the mode was before the window was opened to revert it back
## after the window closes.
var prev_mode : StringName

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options_menu"):
		toggle_window()
	#DEPRECATED: Handled in global script
	#if event.is_action_pressed("ui_cancel"):
		#match global.mode:
			##&"default" : open_window()
			#&"options" : close_window()

func toggle_window():
	if visible:
		close_window()
	else:
		open_window()

func open_window():
	prev_mode = global.mode
	global.mode = &"options"
	visible = true

func close_window():
	if global.mode == &"options":
		global.mode = prev_mode
		prev_mode = ""
		visible = false

func _on_button_return_pressed() -> void:
	close_window()

func _on_button_settings_pressed() -> void:
	close_window()
	%SettingsMenu.popup()

func _on_button_exit_pressed() -> void:
	get_tree().quit()
