extends AlchemyMinigame

func _ready() -> void:
	minigame_buttons.append(%Container/GridContainer/ButtonItem1)
	minigame_buttons.append(%Container/GridContainer/ButtonItem2)
	minigame_buttons.append(%Container/GridContainer/ButtonItem3)
	minigame_buttons.append(%Container/GridContainer/ButtonBellows)


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
	
	#%ItemIcon.texture = items.texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = global.blank_texture
	
	%WindowName.text = "Cauldron"
	global.left_window = self
	visible = true
	global.mode = &"minigame"


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
