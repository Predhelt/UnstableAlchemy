extends AlchemyMinigame

var crush_icon := preload("res://Art/UAPrototype/UI/Minigame/crush.png") ## Icon for the Crush action using the mortar and pestle
var grind_icon := preload("res://Art/UAPrototype/UI/Minigame/grind.png") ## Icon for the Grind action using the mortar and pestle

var combo_buffer : Array[StringName] ## Values are &"up", &"down", &"left", &"right"
var cur_motion_index := 0 ## Current index in the minigame 

var last_pressed_button : Button

## Overrides inherited function to prevent improper minigame functionality
func _process(_delta: float) -> void:
	pass


func _ready() -> void:
	minigame_buttons.append(%ButtonUp)
	minigame_buttons.append(%ButtonDown)
	minigame_buttons.append(%ButtonLeft)
	minigame_buttons.append(%ButtonRight)


func _input(event: InputEvent) -> void: # Override in M&P
	if global.mode != &"minigame" or not visible:
		return # No input events should catch on wrong mode
	if is_crafting and recipes[0].tool_used == "m&p":
		if event.is_action_pressed("minigame_m&p_up") and not minigame_buttons[0].disabled:
			update_combo_input(&"up")
			select_button(%ButtonUp)
		elif event.is_action_pressed("minigame_m&p_down") and not minigame_buttons[1].disabled:
			update_combo_input(&"down")
			select_button(%ButtonDown)
		elif event.is_action_pressed("minigame_m&p_left") and not minigame_buttons[2].disabled:
			update_combo_input(&"left")
			select_button(%ButtonLeft)
		elif event.is_action_pressed("minigame_m&p_right") and not minigame_buttons[3].disabled:
			update_combo_input(&"right")
			select_button(%ButtonRight)
		return # No more input events if minigame is active
	
	#DEPRECATED: Handled in global script
	#if event.is_action_pressed("ui_cancel"):
		#close_window()

## Feedback effects on the associated button when a minigame action occurs
func select_button(button: Button):
	if last_pressed_button:
		if last_pressed_button != button:
			last_pressed_button.scale *= 1.25
		else:
			return # If the last pressed button is the current pressed button, no further action.
	button.scale *= 0.8
	last_pressed_button = button


func begin_minigame():
	%ButtonStart.disabled = true
	cur_motion_index = 0
	
	for button in minigame_buttons:
		button.disabled = false
	
	slider.value = 0
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = "Start!"
	is_crafting = true

##
## Add the given action input to the buffer of inputs, then check to see if the sequence of
## inputs match a valid combination. If so, add the equipment action to the current procedure and
## clear the action input buffer then check to see if the procedure is completed. If so,
## check the list of recipes to see if the procedure on the given item matches a known recipe.
##
func update_combo_input(action: StringName):
	combo_buffer.append(action)
	
	
	if len(combo_buffer) < 4:
		return
	while len(combo_buffer) > 4:
		combo_buffer.pop_front()
	
	if combo_buffer == [&"up", &"down", &"up", &"down"]:
		set_input_action("equipment", 0, crush_icon)
		combo_buffer.clear()
	elif (combo_buffer == [&"left", &"right", &"left", &"right"]
	or combo_buffer == [&"right", &"left", &"right", &"left"]):
		set_input_action("equipment", 1, grind_icon)
		combo_buffer.clear()
	elif(combo_buffer == [&"up", &"right", &"down", &"left"]
	 or combo_buffer == [&"up", &"left", &"down", &"right"]): # Left or right rotation
		pass # Scrape / Squeeze?
	
	if cur_motion_index > 4:
		is_crafting = false
		check_results()

##
## Overrides inherited function. Once a valid input configuration is recognized,
## this function is called to set the associated input action in the minigame to the current index.
##
func set_input_action(type: String, id: int, icon: Texture2D):
	var input_action := ProcedureInputAction.new()
	input_action.type = type
	input_action.id = id
	cur_craft_procedure.input_actions[cur_motion_index] = input_action
	
	%MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children()[cur_motion_index].texture = icon
	cur_motion_index += 1
	slider.value = cur_motion_index

## Overrides inherited function.
func matching_recipe() -> Recipe:
	for recipe in recipes:
		if len(recipe.ingredients) != 1:
			continue
		## Check if the M&P is using the ingredient in the recipe
		var is_using_ingredient := false
		for cur_ing in cur_craft_ingredients:
			if cur_ing.id == recipe.ingredients[0].id:
				is_using_ingredient = true
		if not is_using_ingredient:
			continue
		## Check if the procedure matches the recipe's
		if recipe.procedure:
			if recipe.procedure.compare(cur_craft_procedure):
				return recipe
		else:
			print("Error: No procedure for recipe ID " + str(recipe.id))
	return

func open_window():
	## Reset the window before opening
	cur_craft_procedure = Procedure.new()
	%ButtonStart.disabled = false
	for button in minigame_buttons:
		button.disabled = true
	%MinigameProgressBar/ProgressSlider.value = 0
	%ItemIcon.texture = cur_craft_ingredients[0].texture
	for tb in %MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children():
		tb.texture = global.blank_texture
	
	%WindowName.text = "Mortar and Pestle"
	global.left_window = self
	visible = true
	global.mode = &"minigame"


func _on_button_start_pressed() -> void:
	begin_minigame()

## DEPRECATED
func _on_button_grind_pressed() -> void:
	set_input_action("equipment", 0, %Container/ButtonCrush.icon)

## DEPRECATED
func _on_button_crush_pressed() -> void:
	set_input_action("equipment", 1, %Container/ButtonGrind.icon)


func _on_button_up_pressed() -> void:
	update_combo_input(&"up")
	select_button(%ButtonUp)


func _on_button_down_pressed() -> void:
	update_combo_input(&"down")
	select_button(%ButtonDown)


func _on_button_left_pressed() -> void:
	update_combo_input(&"left")
	select_button(%ButtonLeft)


func _on_button_right_pressed() -> void:
	update_combo_input(&"right")
	select_button(%ButtonRight)
