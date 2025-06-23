extends AlchemyMinigame
#TODO: Make icon for grind and crush buttons
func _ready() -> void:
	minigame_buttons.append($ButtonCrush)
	minigame_buttons.append($ButtonGrind)


func open_window(items: Array[Item]):
	# Reset the window before opening
	
	cur_craft_ingredients = items
	cur_craft_procedure = Procedure.new()
	%ButtonStart.disabled = false
	for button in minigame_buttons:
		button.disabled = true
	%MinigameProgressBar/ProgressSlider.value = 0
	%ItemIcon.texture = items[0].texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = global.blank_texture
	
	visible = true
	#global.mode = &"menu"
	add_to_group("menu")
	print(get_tree().get_nodes_in_group("menu"))


func _on_button_start_pressed() -> void:
	begin_minigame()
	
func _on_button_grind_pressed() -> void:
	set_input_action("equipment", 0, $ButtonCrush.icon)

func _on_button_crush_pressed() -> void:
	set_input_action("equipment", 1, $ButtonGrind.icon)
