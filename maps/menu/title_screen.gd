extends Control

## Which page is currently being displayed.
var current_page_ref: Control

func _ready() -> void:
	$LabelVersion.text = "Version: %s (Demo)" % ProjectSettings.get_setting("application/config/version")
	UserVariables.reset_variables()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $ButtonBack.visible:
			_on_button_back_pressed()

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
	if $PlayTypePage/ButtonLoad/SaveSelectPopup.item_count == 0:
		Global.emit_notification("No save data found.")
	else:
		$PlayTypePage/ButtonLoad/SaveSelectPopup.show()


func _on_button_entered() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "hover"

## Open the menu buttons for selecting what to play
func _on_button_play_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$MainPage.visible = false
	current_page_ref = $PlayTypePage
	$ButtonBack.visible = true
	$PlayTypePage.visible = true


func _on_button_level_select_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	if $PlayTypePage/ButtonLevelSelect/SaveSelectUVPopup.item_count == 1:
		_on_save_select_uv_popup_index_pressed(0)
	else:
		$PlayTypePage/ButtonLevelSelect/SaveSelectUVPopup.show()


func _on_save_select_uv_popup_index_pressed(_index: int) -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	$PlayTypePage.visible = false
	current_page_ref = $LevelSelectPage
	$ButtonBack.visible = true
	$LevelSelectPage.visible = true


func _on_button_back_pressed() -> void:
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	
	$LabelSaveDataType.visible = false
	if current_page_ref == $PlayTypePage:
		current_page_ref.visible = false
		$MainPage.visible = true
		$ButtonBack.visible = false
	else: # Assumeed the page is LevelSelectPage
		current_page_ref.visible = false
		current_page_ref = $PlayTypePage
		current_page_ref.visible = true
		
