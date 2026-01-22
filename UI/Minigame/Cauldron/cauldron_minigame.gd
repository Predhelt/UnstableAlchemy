extends AlchemyMinigame

func _ready() -> void:
	minigame_buttons.append(%Container/GridContainer/ButtonItem1)
	minigame_buttons.append(%Container/GridContainer/ButtonItem2)
	minigame_buttons.append(%Container/GridContainer/ButtonItem3)
	minigame_buttons.append(%Container/GridContainer/ButtonBellows)

func _input(event: InputEvent) -> void: # Override in M&P
	if global.mode != &"minigame" or not visible:
		return ## No input events should catch on wrong mode
	if is_crafting and recipes[0].tool_used == "cauldron":
		if event.is_action_pressed("minigame_cauldron_action_1") and not minigame_buttons[0].disabled:
			set_input_action("item", cur_craft_ingredients[0].id, minigame_buttons[0].icon)
		elif event.is_action_pressed("minigame_cauldron_action_2") and not minigame_buttons[1].disabled:
			set_input_action("item", cur_craft_ingredients[1].id, minigame_buttons[1].icon)
		elif event.is_action_pressed("minigame_cauldron_action_3") and not minigame_buttons[2].disabled:
			set_input_action("item", cur_craft_ingredients[2].id, minigame_buttons[2].icon)
		elif event.is_action_pressed("minigame_cauldron_action_4") and not minigame_buttons[3].disabled:
			set_input_action("equipment", 0, minigame_buttons[3].icon) # Bellows
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
				minigame_buttons[i].icon = global.blank_texture
	%MinigameProgressBar/ProgressSlider.value = 0
	
	#%ItemIcon.texture = items.texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = global.blank_texture
	
	%WindowName.text = "Cauldron"
	global.left_window = self
	visible = true
	global.mode = window_mode


func _on_button_start_pressed() -> void:
	begin_minigame()

func _on_button_item_1_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[0].id, %Container/GridContainer/ButtonItem1.icon)

func _on_button_item_2_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[1].id, %Container/GridContainer/ButtonItem2.icon)

func _on_button_item_3_pressed() -> void:
	set_input_action("item", cur_craft_ingredients[2].id, %Container/GridContainer/ButtonItem3.icon)

func _on_button_bellows_pressed() -> void:
	set_input_action("equipment", 0, %Container/GridContainer/ButtonBellows.icon)
