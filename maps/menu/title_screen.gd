extends Control

var save_select_popup_ref : PackedScene = preload("res://level_components/ui/windows/save_select_popup.tscn")

func _ready() -> void:
	$LabelVersion.text = "Version: %s (Prototype)" % ProjectSettings.get_setting("application/config/version")
	UserVariables.reset_variables()

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
	var save_select : PopupMenu = save_select_popup_ref.instantiate()
	add_child(save_select)
	save_select.position = $VBoxContainer/ButtonLoad.global_position


func _on_button_entered() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "hover"

## Open the menu buttons for selecting what to play
func _on_button_play_pressed() -> void:
	$MainPage.visible = false
	$PlayTypePage.visible = true
