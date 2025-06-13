extends AlchemyMinigame
#TODO: make icon for bellows button
func _ready() -> void:
	minigame_buttons.append($GridContainer/ButtonItem1)
	minigame_buttons.append($GridContainer/ButtonItem2)
	minigame_buttons.append($GridContainer/ButtonItem3)
	minigame_buttons.append($GridContainer/ButtonBellows)


func open_window(items: Array[Item]):
	# Reset the window before opening
	
	cur_craft_ingredients = items
	cur_craft_procedure = Procedure.new()
	%ButtonStart.disabled = false
	for i in len(minigame_buttons):
		minigame_buttons[i].disabled = true
		if i < 3:
			if items[i]:
				minigame_buttons[i].icon = items[i].texture
			else:
				minigame_buttons[i].icon = global.blank_texture
	%MinigameProgressBar/ProgressSlider.value = 0
	#TODO: Set button textures (or something) to indicate which items are attached to which buttons
	#%ItemIcon.texture = items.texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = global.blank_texture
	
	visible = true
	global.mode = &"craft_minigame"


func _on_button_start_pressed() -> void:
	begin_minigame()

func _on_button_item_1_pressed() -> void:
	set_input_action("item", 0, $GridContainer/ButtonItem1.icon)

func _on_button_item_2_pressed() -> void:
	set_input_action("item", 1, $GridContainer/ButtonItem2.icon)

func _on_button_item_3_pressed() -> void:
	set_input_action("item", 2, $GridContainer/ButtonItem3.icon)

func _on_button_bellows_pressed() -> void:
	set_input_action("equipment", 3, $GridContainer/ButtonBellows.icon)
