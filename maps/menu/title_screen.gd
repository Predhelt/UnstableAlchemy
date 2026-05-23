extends Control

var save_select_popup_ref : PackedScene = preload("res://level_components/ui/windows/popups/save_select_popup.tscn")
## Which page is currently being displayed.
var current_page_ref: Control
## Which page of the title screen the back button will lead to.
var previous_page_ref: Control

func _ready() -> void:
	$LabelVersion.text = "Version: %s (Demo)" % ProjectSettings.get_setting("application/config/version")
	UserVariables.reset_variables()
	$PlayTypePage/ButtonLevelSelect/SaveSelectUVPopup.position = $PlayTypePage/ButtonLevelSelect.global_position

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
	save_select.position = $PlayTypePage/ButtonLoad.global_position


func _on_button_entered() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "hover"

## Open the menu buttons for selecting what to play
func _on_button_play_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$MainPage.visible = false
	previous_page_ref = $MainPage
	current_page_ref = $PlayTypePage
	$ButtonBack.visible = true
	$PlayTypePage.visible = true


func _on_button_level_select_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PlayTypePage/ButtonLevelSelect/SaveSelectUVPopup.show()


func _on_save_select_uv_popup_index_pressed(_index: int) -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PlayTypePage.visible = false
	previous_page_ref = $PlayTypePage
	current_page_ref = $LevelSelectPage
	$ButtonBack.visible = true
	$LevelSelectPage.visible = true


func _on_button_back_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	current_page_ref.visible = false
	if previous_page_ref == $MainPage:
		$ButtonBack.visible = false
	previous_page_ref.visible = true
