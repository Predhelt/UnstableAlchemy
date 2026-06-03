extends AlchemyMinigame

var empty_slot = preload("res://art/pack/objects/object_gray.png")

var craft_precisions := [
	0.35,
	0.65,
	0.9
]

## The accuracy of each input as a modifier from 0 to 1.
## Based on the cauldron precision window hit.
var input_accuracies: Array[float] = [0,0,0,0,0]

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
			slider.value += (delta * Global.cauldron_craft_speed_mult)
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
	
	set_progress_slider_precision_window_width(0, (1.0-craft_precisions[0])*104)
	set_progress_slider_precision_window_width(1, (1.0-craft_precisions[1])*104)
	set_progress_slider_precision_window_width(2, (1.0-craft_precisions[2])*104)
	set_progress_slider_precision_window_visibilities(true)
	
	%WindowName.text = "Cauldron"
	Global.left_window = self
	visible = true
	Global.mode = window_mode
	$MinigameAudioStream.play()
	$MinigameAudioStream["parameters/switch_to_clip"] = &"open"
	window_opened.emit()

## Checks to see if the input is near a tick on the progress bar. If so,
## sets the nearest tick image and information equal to the given information.
## type is the type of input action that is being set. For instance, "item" or "equipment".
## id is the id of the item being used, if any.
## icon is the image of the item / tool being used in the input.
func set_input_action(type: String, id: int, icon: Texture2D) -> void:
	var temp: Array[int] = _get_nearest_tick()
	var nearest_tick : int = temp[0]
	var precision: int = temp[1]
	
	if nearest_tick < 0 or nearest_tick >= cur_craft_procedure.input_actions.size():
		$EffectsAudioStream["parameters/switch_to_clip"] = &"miss"
		return
	
	set_progress_slider_precision_window_visibility(nearest_tick, false)
	
	var input_action := ProcedureInputAction.new()
	input_action.type = type
	input_action.id = id
	if not cur_craft_procedure.input_actions[nearest_tick]:
		cur_craft_procedure.input_actions[nearest_tick] = input_action
		input_accuracies[nearest_tick] = craft_precisions[precision]
		%MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children()[nearest_tick].texture = icon
		if input_action.type == "equipment" and input_action.id == 2: # Bellows
			$EffectsAudioStream["parameters/switch_to_clip"] = &"bellows"
		else:
			$EffectsAudioStream["parameters/switch_to_clip"] = &"drop"

## Used by the cauldron to determine the segment on the progress bar that the
## progress is closest. -1 if not close to any.
## Also returns the precision window, if any, by index. Same index of [member craft_precisions]
func _get_nearest_tick() -> Array[int]:
	var nearest_tick := -1
	
	var tick_mod : float = fmod(((slider.value) + (tick_value / 2.0)), tick_value)
	tick_mod = tick_mod / tick_value
	var lower_bound : float = craft_precisions[0]/2
	var upper_bound : float = 0.5+((1-craft_precisions[0])/2)
	if tick_mod < upper_bound and tick_mod > lower_bound:
		nearest_tick = int((slider.value + (tick_value / 2.0)) / tick_value) - 1
	else:
		return [nearest_tick, -1] # Miss input.
	lower_bound = craft_precisions[1]/2
	upper_bound = 0.5+((1-craft_precisions[1])/2)
	if not tick_mod < upper_bound and tick_mod > lower_bound:
		return [nearest_tick, 0] # Near Miss.
	lower_bound = craft_precisions[2]/2
	upper_bound = 0.5+((1-craft_precisions[2])/2)
	if tick_mod < upper_bound and tick_mod > lower_bound:
		return [nearest_tick, 2] # Perfect Hit.
	else:
		return [nearest_tick, 1] # Good Hit.

## Overrides parent function.
## Upon completion of the minigame, check the user inputs and compare them to the
## list of crafting recipe to determine if the procedure and ingredients match. If not, 
## produces the failed item. If so, produces the matching item. Produced items
## are added to the character's inventory.
func check_results():
	var product_recipe := matching_recipe()
	var product_item : Item = null
	if product_recipe:
		$EffectsAudioStream.play()
		$EffectsAudioStream["parameters/switch_to_clip"] = "success"
		product_item = product_recipe.product_item.duplicate()
		var precision_avg: float = get_avg_precision(product_recipe)
		# Bonus amount should be in the range of 0 to double the default product quantity based on average precision.
		product_item.qty = roundi(product_recipe.product_item_amount + 
			(product_recipe.product_item_amount* # The default quantity of items produced
				((precision_avg-craft_precisions[0])* # Change precision range to start from 0
					(1/(craft_precisions[2]-craft_precisions[0]))))) # Inverse of difference between highest and lowest precision
	else:
		$EffectsAudioStream.play()
		$EffectsAudioStream["parameters/switch_to_clip"] = "fail"
		for item in cur_craft_ingredients:
			if item and item.id == 10: # Mysterious Crystal
				product_item = FAILED_CRYSTAL_CRAFT.product_item.duplicate()
				break
		if not product_item:
			product_item = FAILED_CRAFT.product_item.duplicate()

	var effect_instance = items_gained_effect.instantiate()
			
	effect_instance.add_item(product_item)
	effect_instance.scale = Vector2(1.3, 1.3)
	tool_ref.add_child(effect_instance)
	
	cur_craft_ingredients = [] ## Consider the ingredients as used, clear the list.
	craft_completed.emit(product_item, product_recipe)
	#inventory_menu_ref.add_produced_item(product_item, product_recipe)
	last_item_produced = product_item

## Gets the average precision of inputs for the minigame product
## based on the window the inputs were pressed.
func get_avg_precision(product_recipe: Recipe) -> float:
	var avg: float = 0.0
	var count: int = 0
	for i in range(product_recipe.procedure.input_actions.size()):
		if product_recipe.procedure.input_actions[i]:
			avg += input_accuracies[i]
			count += 1
	avg /= count
	return avg


func _on_button_start_pressed() -> void:
	input_accuracies = [0,0,0,0,0]
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
