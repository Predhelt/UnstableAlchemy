extends UIWindow

## Keeps track of what the mode was before the window was opened to revert it back
## after the window closes.
var prev_mode : StringName

func _init() -> void:
	window_mode = &"options"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options_menu"):
		toggle_window()

func toggle_window():
	if visible:
		close_window()
	else:
		open_window()

func open_window():
	if not Global.center_window:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
		prev_mode = Global.mode
		Global.mode = window_mode
		Global.center_window = self
		visible = true
		get_tree().current_scene.find_child("AudioStreams").pause_music()

func close_window():
	if Global.mode == window_mode:
		Global.mode = prev_mode
		Global.center_window = null
		prev_mode = ""
		visible = false
		get_tree().current_scene.find_child("AudioStreams").resume_music()

## Close the options menu and return to the game.
func _on_button_return_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	close_window()

## Close the options menu and open the settings menu.
func _on_button_settings_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	close_window()
	$"../SettingsMenu".popup()

## Close the game.
func _on_button_exit_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PopupConfirmation.popup()


func _on_button_save_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	Global.save_game()


func _on_button_load_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	Global.load_game()


func _on_button_cancel_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PopupConfirmation.hide()


func _on_button_quit_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	get_tree().quit()


func _on_button_entered() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"
