class_name AlchemyMinigame extends Panel
#TODO: Add comments to functions

signal item_produced(item: Item, recipe : Recipe) ## Signal sent when the item is completed and added to the inventory
signal open_inventory()

var minigame_buttons : Array[Button] ## Buttons used during the minigame. Set by inherited class.
var tool_ref : Control ## Reference to associated inventory tool. Set by Inventory.

@export var item_gained_effect := preload("res://Effects/items_gained_effect_ui.tscn")
@onready var slider := %MinigameProgressBar/ProgressSlider
@onready var tick_value : float = float(slider.max_value)/(slider.tick_count-1) ##The value of each tick
var recipes : Array[Recipe] ## List of recipes using the associated tool

var cur_craft_ingredients : Array[Item] ## Item used in the recipe
var cur_craft_procedure : Procedure ## List of input actions of the current craft attempt
var is_crafting := false ## Tracks if the minigame is currently active

#TODO: Determine if craft difficulty could be set dynamically
@export var input_window_ratio := 0.5 ## The window of acceptable input for each tick. Smaller values means tighter timing
var failed_craft : Recipe = preload("res://Alchemy/Recipes/failed_craft.tres") ##ID for failed craft is 999


func _process(delta: float) -> void:
	for i in len(minigame_buttons): # Set hotkey text for each button
		minigame_buttons[i].text = ("(" +
			InputMap.action_get_events("minigame_cauldron_action_"+str(i+1))[0].as_text().replace(' (Physical)','') + ")")
	
	if is_crafting:
		if slider.value < slider.max_value:
			slider.value += delta
		else:
			is_crafting = false
			check_results()


func _input(event: InputEvent) -> void: # Override in M&P
	if global.mode != &"minigame" or not visible:
		return # No input events should catch on wrong mode
	if is_crafting and recipes[0].tool_used == "cauldron":
		if event.is_action_pressed("minigame_cauldron_action_1") and not minigame_buttons[0].disabled:
			set_input_action("item", cur_craft_ingredients[0].id, minigame_buttons[0].icon)
		elif event.is_action_pressed("minigame_cauldron_action_2") and not minigame_buttons[1].disabled:
			set_input_action("item", cur_craft_ingredients[1].id, minigame_buttons[1].icon)
		elif event.is_action_pressed("minigame_cauldron_action_3") and not minigame_buttons[2].disabled:
			set_input_action("item", cur_craft_ingredients[2].id, minigame_buttons[2].icon)
		elif event.is_action_pressed("minigame_cauldron_action_4") and not minigame_buttons[3].disabled:
			set_input_action("equipment", 0, minigame_buttons[3].icon) # Bellows
		pass
	
	if event.is_action_pressed("ui_cancel"):
		close_window()


func open_window(items: Array[Item]): ## Template used to determine how the minigame should be set up when the window is opened
	cur_craft_ingredients = items # Used to remove warning


func close_window():
	is_crafting = false
	visible = false
	remove_from_group("menu")
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = ""
	print(get_tree().get_nodes_in_group("menu"))
	if get_tree().get_nodes_in_group("menu").is_empty():
		global.mode = &"default"


func previous_window():
	is_crafting = false
	visible = false
	remove_from_group("menu")
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = ""
	open_inventory.emit() # Mode gets set by inventory


func begin_minigame():
	%ButtonStart.disabled = true
	
	for i in len(cur_craft_ingredients): #NOTE: This works for Mortar and Pestle despite M&P not following this structure since there are only 2 buttons and 1 ingredient.
		if cur_craft_ingredients[i]:
			minigame_buttons[i].disabled = false
	minigame_buttons[-1].disabled = false
	
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = "Ready..."
	$StartupDelay.start()

func _on_startup_delay_timeout() -> void:
	slider.value = 0
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = "Start!"
	is_crafting = true


func check_results():
	var product_recipe := matching_recipe()
	var product_item : Item = failed_craft.product_item.duplicate()
	if product_recipe:
		product_item = product_recipe.product_item.duplicate()
		product_item.qty = product_recipe.product_item_amount
	#TODO: Show effect and resulting item. Give option to craft more?
	var effect_instance = item_gained_effect.instantiate()
			
	effect_instance.add_item(product_item)
	effect_instance.scale = Vector2(1.3, 1.3)
	tool_ref.add_child(effect_instance)
	
	item_produced.emit(product_item, product_recipe)
	previous_window()


func matching_recipe() -> Recipe:
	for recipe in recipes:
		if len(recipe.ingredients) < 1 or len(recipe.ingredients) > 3:
			continue
		#var is_matching_ingredients := true # Checks if ingredients match
		#for ingredient in recipe.ingredients:
			#var is_cur_match := false
			#for cur_ingredient in cur_craft_ingredients:
				#if not cur_ingredient:
					#break
				#if ingredient.id == cur_ingredient.id:
					#is_cur_match = true
			#if not is_cur_match:
				#is_matching_ingredients = false
				#break
		#if not is_matching_ingredients:
			#continue
		if recipe.procedure:
			if recipe.procedure.compare(cur_craft_procedure):
				return recipe
	return null


func set_input_action(type: String, id: int, icon: Texture2D):
	var nearest_tick = _get_nearest_tick()
	
	if nearest_tick < 0:
		return
	
	var input_action := ProcedureInputAction.new()
	input_action.type = type
	input_action.id = id
	if not cur_craft_procedure.input_actions[nearest_tick]:
		cur_craft_procedure.input_actions[nearest_tick] = input_action
		%MinigameProgressBar/ProgressSlider/ProcedureIcons.get_children()[nearest_tick].texture = icon
		


func _get_nearest_tick() -> int:
	var nearest_tick := -1
	
	var tick_mod : float = fmod((slider.value + (tick_value / 2.0)), tick_value)
	tick_mod = tick_mod / tick_value
	var lower_bound := (1-input_window_ratio)/2
	var upper_bound := input_window_ratio+((1-input_window_ratio)/2)
	if tick_mod < upper_bound and tick_mod > lower_bound:
		nearest_tick = int((slider.value + (tick_value / 2.0)) / tick_value) - 1
	else: # Bad input. TODO: Determine if the input for the tick should be locked on bad input.
		pass
	
	return nearest_tick


func _on_button_close_pressed() -> void:
	close_window()


func _on_button_back_pressed() -> void:
	previous_window()
