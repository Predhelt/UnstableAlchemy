extends Control

func _ready() -> void:
	$LabelVersion.text = "Version: %s (Prototype)" % ProjectSettings.get_setting("application/config/version")

## Opens the level that was selected. Returns whether or not the level was opened successfuly.
func open_level() -> bool:
	return false


func _on_button_settings_pressed() -> void:
	$AudioStreamPlayer2D.play()
	if not $SettingsMenu.visible:
		$SettingsMenu.popup()
	else:
		$SettingsMenu.hide()


func _on_button_exit_pressed() -> void:
	$AudioStreamPlayer2D.play()
	$PopupConfirmation.popup()


func _on_button_load_pressed() -> void:
	$AudioStreamPlayer2D.play()
	Global.load_game()
