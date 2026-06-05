extends UIWindow

## Keeps track of what the mode was before the window was opened to revert it back
## after the window closes.
var prev_mode : StringName

func _init() -> void:
	window_mode = &"options"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options_menu"):
		toggle_window()
	if event.is_action_pressed("reset_level"):
		$PopupResetConfirmation.show()

func toggle_window():
	if visible:
		close_window()
	else:
		open_window()

func open_window():
	if not Global.center_window and not Global.left_window and not Global.right_window:
		configure_progression_data()
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
		prev_mode = Global.mode
		Global.mode = window_mode
		Global.center_window = self
		visible = true
		window_opened.emit()

func close_window():
	if Global.mode == window_mode:
		Global.mode = prev_mode
		Global.center_window = null
		prev_mode = ""
		visible = false
		window_closed.emit()

## Uses the [member current_save_slot] to get data from UserVariables
## to configure the progression data.
func configure_progression_data():
	$ProgressionPanel/ProgressionContainer/LabelSlotName.text = "Slot %s" % Global.current_save_slot
	if not FileAccess.file_exists("user://saves/slot%s.save" % Global.current_save_slot):
		$SaveSelectPage/ButtonStart.text = "New Game"
		$ProgressionPanel/ProgressionContainer/LabelLevelsCleared.text = "Levels Cleared: 0"
		$ProgressionPanel/ProgressionContainer/LabelBonusCount.visible = false
		$ProgressionPanel/ProgressionContainer/BonusIconsContainer.visible = false
		return
	
	if not UserVariables.has_looped:
		$ProgressionPanel/ProgressionContainer/LabelLevelsCleared.text = (
			"Levels Cleared: %s" % UserVariables.level_highest_cleared_index
		)
		$ProgressionPanel/ProgressionContainer/LabelBonusCount.visible = false
		$ProgressionPanel/ProgressionContainer/BonusIconsContainer.visible = false
		return
	# User has looped
	$ProgressionPanel/ProgressionContainer/LabelLevelsCleared.text = "LOOPED"
	
	var bonus_count := 0
	if UserVariables.books_read.find(2000) != -1:
		$ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureLetter.visible = true
		bonus_count += 1
	else: $ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureLetter.visible = false
	if UserVariables.knows_recipe_id(510):
		$ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureRecipe.visible = true
		bonus_count += 1
	else: $ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureRecipe.visible = false
	if UserVariables.books_read.find(2003) != -1:
		$ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureCrystalHint.visible = true
		bonus_count += 1
	else: $ProgressionPanel/ProgressionContainer/BonusIconsContainer/TextureCrystalHint.visible = false
		
	$ProgressionPanel/ProgressionContainer/LabelBonusCount.text = "Bonus: %s/3" % bonus_count
	$ProgressionPanel/ProgressionContainer/LabelBonusCount.visible = true
	$ProgressionPanel/ProgressionContainer/BonusIconsContainer.visible = true



func _on_button_entered() -> void:
	if not is_inside_tree():
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"


func _on_button_pressed() -> void:
	if not is_inside_tree():
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"

## Close the options menu and return to the game.
func _on_button_return_pressed() -> void:
	close_window()

## Close the options menu and open the settings menu.
func _on_button_settings_pressed() -> void:
	close_window()
	$"../SettingsMenu".popup()

## Close the game.
func _on_button_exit_pressed() -> void:
	$PopupQuitConfirmation.popup()


func _on_button_save_pressed() -> void:
	Global.save_game.call_deferred()


func _on_button_load_pressed() -> void:
	Global.load_game()


func _on_button_cancel_pressed() -> void:
	$PopupQuitConfirmation.hide()


func _on_button_quit_pressed() -> void:
	get_tree().quit()
