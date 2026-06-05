extends Control

## Maximum number of save slots available.
const MAX_SAVE_SLOTS: int = 3

@export_file_path var default_loaded_level = "res://maps/training/1_ruins_entrance.tscn"
## Which page is currently being displayed.
var current_page_ref: Control
## Tracks if the current save slot is empty, as in, has no user data.
var is_slot_empty: bool = true


func _ready() -> void:
	$LabelVersion.text = "v%s (Demo, Alpha)" % ProjectSettings.get_setting("application/config/version")
	UserVariables.reset_variables()
	$ButtonCredits.visible = true
	$CreditsPanel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $CreditsPanel.visible:
			$CreditsPanel.visible = false
		elif $ButtonBack.visible:
			_on_button_back_pressed()


func _on_button_settings_pressed() -> void:
	if not $SettingsMenu.visible:
		$SettingsMenu.popup()
	else:
		$SettingsMenu.hide()


func _on_button_exit_pressed() -> void:
	$PopupQuitConfirmation.popup()


func _on_button_entered() -> void:
	if not is_inside_tree():
		return
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "hover"


func _on_button_pressed() -> void:
	if not is_inside_tree():
		return
	$AudioStreams/AudioStreamPlayer.play()
	$AudioStreams/AudioStreamPlayer["parameters/switch_to_clip"] = "press"

## Open the menu buttons for selecting what to play
func _on_button_play_pressed() -> void:
	$MainPage.visible = false
	current_page_ref = $SaveSelectPage
	$ButtonBack.visible = true
	
	Global.set_save_slot(0)
	configure_save_slot_data()
	current_page_ref = $SaveSelectPage
	$SaveSelectPage.visible = true

## Uses the [member current_save_slot] to get data from UserVariables
## to configure the save slot page.
func configure_save_slot_data():
	$SaveSelectPage/VBoxContainer/LabelSlotName.text = "Slot %s" % Global.current_save_slot
	if not FileAccess.file_exists("user://saves/slot%s.save" % Global.current_save_slot):
		$SaveSelectPage/ButtonStart.text = "New Game"
		is_slot_empty = true
		$SaveSelectPage/ButtonClearSave.disabled = true
		$SaveSelectPage/VBoxContainer/LabelLevelsCleared.text = "Levels Cleared: 0"
		$SaveSelectPage/VBoxContainer/LabelBonusCount.visible = false
		$SaveSelectPage/VBoxContainer/BonusIconsContainer.visible = false
		$SaveSelectPage/ButtonLevelSelect.visible = false
		return
	
	$SaveSelectPage/ButtonStart.text = "Resume"
	is_slot_empty = false
	$SaveSelectPage/ButtonClearSave.disabled = false
	
	if not UserVariables.has_looped:
		$SaveSelectPage/VBoxContainer/LabelLevelsCleared.text = (
			"Levels Cleared: %s" % UserVariables.level_highest_cleared_index
		)
		$SaveSelectPage/VBoxContainer/LabelBonusCount.visible = false
		$SaveSelectPage/VBoxContainer/BonusIconsContainer.visible = false
		$SaveSelectPage/ButtonLevelSelect.visible = false
		return
	# User has looped
	$SaveSelectPage/VBoxContainer/LabelLevelsCleared.text = "LOOPED"
	
	var bonus_count := 0
	if UserVariables.books_read.find(2000) != -1:
		$SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureLetter.visible = true
		bonus_count += 1
	else: $SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureLetter.visible = false
	if UserVariables.knows_recipe_id(510):
		$SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureRecipe.visible = true
		bonus_count += 1
	else: $SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureRecipe.visible = false
	if UserVariables.books_read.find(2003) != -1:
		$SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureCrystalHint.visible = true
		bonus_count += 1
	else: $SaveSelectPage/VBoxContainer/BonusIconsContainer/TextureCrystalHint.visible = false
		
	$SaveSelectPage/VBoxContainer/LabelBonusCount.text = "Bonus: %s/3" % bonus_count
	$SaveSelectPage/VBoxContainer/LabelBonusCount.visible = true
	$SaveSelectPage/VBoxContainer/BonusIconsContainer.visible = true
	
	$SaveSelectPage/ButtonLevelSelect.visible = true


func _on_button_back_pressed() -> void:
	$LabelSaveDataType.visible = false
	if current_page_ref == $SaveSelectPage:
		current_page_ref.visible = false
		$MainPage.visible = true
		$ButtonBack.visible = false
	else: # Assumeed the page is LevelSelectPage
		current_page_ref.visible = false
		current_page_ref = $SaveSelectPage
		current_page_ref.visible = true
		


func _on_button_credits_pressed() -> void:
	$CreditsPanel.visible = true


func _on_credits_button_close_pressed() -> void:
	$CreditsPanel.visible = false

# Save Slot Buttons

func _on_button_saves_start_pressed() -> void:
	if is_slot_empty:
		Global.change_scene(default_loaded_level)
	else:
		Global.load_game()


func _on_button_saves_previous_pressed() -> void:
	if Global.current_save_slot < 1:
		Global.set_save_slot(MAX_SAVE_SLOTS-1)
	else:
		Global.set_save_slot(Global.current_save_slot - 1)
	configure_save_slot_data()


func _on_button_saves_next_pressed() -> void:
	if Global.current_save_slot >= MAX_SAVE_SLOTS-1:
		Global.set_save_slot(0)
	else:
		Global.set_save_slot(Global.current_save_slot + 1)
	configure_save_slot_data()


func _on_button_saves_level_select_pressed() -> void:
	$SaveSelectPage.visible = false
	
	var c: int = UserVariables.level_highest_cleared_index
	for level_button in %GridContainerButtons.get_children():
		if c > 0: #NOTE: Not necessary right now since can only select when looped.
			level_button.visible = true
			c -= 1
		else:
			level_button.visible = false
	
	current_page_ref = $LevelSelectPage
	$LevelSelectPage.visible = true


func _on_button_saves_clear_save_pressed() -> void:
	$PopupClearConfirmation.show()


func _on_popup_clear_confirmation_confirmed() -> void:
	configure_save_slot_data()
