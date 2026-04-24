extends AlchemyMinigame

var empty_slot = preload("res://art/pack/objects/object_gray.png")

func _ready() -> void:
	minigame_buttons.append(%Container/GridContainer/ButtonItem1)
	minigame_buttons.append(%Container/GridContainer/ButtonItem2)
	minigame_buttons.append(%Container/GridContainer/ButtonItem3)
	minigame_buttons.append(%Container/GridContainer/ButtonBellows)

## Sets minigame input displays, updates minigame timers,
## checks to see if the crafting is complete.
func _process(delta: float) -> void:
	#if Global.mode != window_mode: #FIXME: on wrong mode, so disabling check
		#return ## Do not continue minigame if another mode has priority.
	for i in len(minigame_buttons): ## Set hotkey text for each button
		minigame_buttons[i].text = ("(" +
			InputMap.action_get_events("minigame_cauldron_action_"+str(i+1))[0].as_text().replace(
				' - Physical','') + ")")	
	if is_crafting:
		if slider.value < slider.max_value:
			slider.value += delta
		else:
			is_crafting = false
			check_results()
			previous_window()


func _input(event: InputEvent) -> void:
	if Global.mode != window_mode or not visible:
		return ## No input events should catch on wrong mode or not visible
	if is_crafting and recipes[0].tool_used == &"Cauldron":
		if event.is_action_pressed("minigame_cauldron_action_1") and not minigame_buttons[0].disabled:
			set_input_action("item", cur_craft_ingredients[0].id, minigame_buttons[0].icon)
			minigame_buttons[0].disabled = true ## Item is now used in craft, disable button.
		elif event.is_action_pressed("minigame_cauldron_action_2") and not minigame_buttons[1].disabled:
			set_input_action("item", cur_craft_ingredients[1].id, minigame_buttons[1].icon)
			minigame_buttons[1].disabled = true ## Item is now used in craft, disable button.
		elif event.is_action_pressed("minigame_cauldron_action_3") and not minigame_buttons[2].disabled:
			set_input_action("item", cur_craft_ingredients[2].id, minigame_buttons[2].icon)
			minigame_buttons[2].disabled = true ## Item is now used in craft, disable button.
		elif event.is_action_pressed("minigame_cauldron_action_4") and not minigame_buttons[3].disabled:
			set_input_action("equipment", 2, minigame_buttons[3].icon) ## Bellows input
		return

## Opens the cauldron minigame window. Assumes that the cur_craft_ingredients was already set.
func open_window():
	# Reset the window before opening
	cur_craft_procedure = Procedure.new()
	%ButtonStart.disabled = false
	for i in len(minigame_buttons):
		minigame_buttons[i].disabled = true
		if i < 3:
			if cur_craft_ingredients[i]:
				minigame_buttons[i].icon = cur_craft_ingredients[i].texture
			else:
				minigame_buttons[i].icon = Global.blank_texture
	%MinigameProgressBar/ProgressSlider.value = 0
	
	#%ItemIcon.texture = items.texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = empty_slot
	
	slider.max_value = 6 * 2 #TODO: Allow max value to be changed based on difficulty/settings
	slider.tick_count = 7
	tick_value = slider.max_value / (slider.tick_count-1)
	
	%WindowName.text = "Cauldron"
	Global.left_window = self
	visible = true
	Global.mode = window_mode
	$MinigameAudioStream["parameters/switch_to_clip"] = "idle"
	$MinigameAudioStream.play()

## Checks to see if the input is near a tick on the progress bar. If so,
## sets the nearest tick image and information equal to the given information.
## type is the type of input action that is being set. For instance, "item" or "equipment".
## id is the id of the item being used, if any.
## icon is the image of the item / tool being used in the input.
func set_input_action(type: String, id: int, icon: Texture2D) -> void:
	var nearest_tick = _get_nearest_tick()
	
	if nearest_tick < 0:
		$EffectsAudioStream["parameters/switch_to_clip"] = "miss"
		$EffectsAudioStream.play()
		return

	var input_action := ProcedureInputAction.new()
	input_action.type = type
	input_action.id = id
	if not cur_craft_procedure.input_actions[nearest_tick]:
		cur_craft_procedure.input_actions[nearest_tick] = input_action
		%MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children()[nearest_tick].texture = icon
		if input_action.type == "equipment" and input_action.id == 2: # Bellows
			$EffectsAudioStream["parameters/switch_to_clip"] = "bellows"
			$EffectsAudioStream.play()
		else:
			$EffectsAudioStream["parameters/switch_to_clip"] = "drop"
			$EffectsAudioStream.play()
	

## Used by the cauldron to determine the segment on the progress bar that the
## progress is closest to, if any. Modifying the input_window_ratio changes
## how close the progress bar needs to be from a tick.
func _get_nearest_tick() -> int:
	var nearest_tick := -1
	
	var tick_mod : float = fmod(((slider.value) + (tick_value / 2.0)), tick_value)
	tick_mod = tick_mod / tick_value
	var lower_bound := (1-input_window_ratio)/2
	var upper_bound := input_window_ratio+((1-input_window_ratio)/2)
	if tick_mod < upper_bound and tick_mod > lower_bound:
		nearest_tick = int((slider.value + (tick_value / 2.0)) / tick_value) - 1
	else: # Bad input. TODO: Determine if the input for the tick should be locked on bad input.
		pass
	
	return nearest_tick


func _on_button_start_pressed() -> void:
	begin_minigame()

func _on_button_item_1_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[0].id, %Container/GridContainer/ButtonItem1.icon)
	%Container/GridContainer/ButtonItem1.disabled = true

func _on_button_item_2_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[1].id, %Container/GridContainer/ButtonItem2.icon)
	%Container/GridContainer/ButtonItem2.disabled = true

func _on_button_item_3_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[2].id, %Container/GridContainer/ButtonItem3.icon)
	%Container/GridContainer/ButtonItem3.disabled = true

func _on_button_bellows_pressed() -> void:
	set_input_action("equipment", 2, %Container/GridContainer/ButtonBellows.icon)
