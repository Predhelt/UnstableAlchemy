extends Control

func _ready() -> void:
	$LabelVersion.text = "Version: %s (Prototype)" % ProjectSettings.get_setting("application/config/version")

## Opens the level that was selected. Returns whether or not the level was opened successfuly.
func open_level() -> bool:
	return false


func _on_button_settings_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	if not $SettingsMenu.visible:
		$SettingsMenu.popup()
	else:
		$SettingsMenu.hide()


func _on_button_exit_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PopupConfirmation.popup()


func _on_button_load_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	Global.load_game()


func _on_button_entered() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "hover"
