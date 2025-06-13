class_name AlchemyMinigame extends Panel

signal item_produced(item: Item, recipe : Recipe) ## Signal sent when the item is completed and added to the inventory
signal open_inventory()

var minigame_buttons : Array[Button] ## Buttons used during the minigame. Set by inherited class.


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
	if is_crafting:
		if slider.value < slider.max_value:
			slider.value += delta
		else:
			is_crafting = false
			check_results()


func _input(event: InputEvent) -> void:
	if global.mode != &"craft_minigame" or not visible:
		return # No input events should catch on wrong mode
	if is_crafting:
		if event.is_action_pressed("minigame_action_1") and not minigame_buttons[0].disabled:
				if recipes[0].tool_used == "m&p":
					set_input_action("equipment", 0, minigame_buttons[0].icon)
				else:
					set_input_action("item", 0, minigame_buttons[0].icon)
		elif event.is_action_pressed("minigame_action_2") and not minigame_buttons[1].disabled:
			if recipes[0].tool_used == "m&p":
				set_input_action("equipment", 1, minigame_buttons[1].icon)
			else:
				set_input_action("item", 1, minigame_buttons[1].icon)
		elif event.is_action_pressed("minigame_action_3") and not minigame_buttons[2].disabled:
			set_input_action("item", 2, minigame_buttons[2].icon)
		elif event.is_action_pressed("minigame_action_4") and not minigame_buttons[3].disabled:
			set_input_action("equipment", 3, minigame_buttons[3].icon)
		pass
	if event.is_action_pressed("ui_cancel"):
		close_window()


func open_window(items: Array[Item]):
	# Template
	cur_craft_ingredients = items # Used to remove warning


func close_window():
	is_crafting = false
	visible = false
	%MinigameProgressBar/StartupLabel.text = ""
	open_inventory.emit() # Mode gets set by inventory


func begin_minigame():
	$ButtonStart.disabled = true
	
	for i in len(cur_craft_ingredients): #NOTE: This works for Mortar and Pestle despite M&P not following this structure since there are only 2 buttons and 1 ingredient.
		if cur_craft_ingredients[i]:
			minigame_buttons[i].disabled = false
	minigame_buttons[-1].disabled = false
	
	%MinigameProgressBar/StartupLabel.text = "Ready..."
	$StartupDelay.start()

func _on_startup_delay_timeout() -> void:
	slider.value = 0
	%MinigameProgressBar/StartupLabel.text = "Start!"
	is_crafting = true


func check_results():
	var product_recipe := matching_recipe()
	var product_item = failed_craft.product_item.duplicate()
	if product_recipe:
		product_item = product_recipe.product_item.duplicate()
	#TODO: Show effect and resulting item. Give option to craft more?
	var effect_instance = item_gained_effect.instantiate()
			
	effect_instance.add_item(product_item)
	effect_instance.scale = Vector2(1.3, 1.3)
	%ToolIcon.add_child(effect_instance)
	
	item_produced.emit(product_item, product_recipe)
	close_window()


func matching_recipe() -> Recipe:
	for recipe in recipes:
		if len(recipe.ingredients) < 1 or len(recipe.ingredients) > 3:
			continue
		var is_matching_ingredients := true # Checks if ingredients match
		for ingredient in recipe.ingredients:
			var is_cur_match := false
			for cur_ingredient in cur_craft_ingredients:
				if not cur_ingredient:
					break
				if ingredient.id == cur_ingredient.id:
					is_cur_match = true
			if not is_cur_match:
				is_matching_ingredients = false
				break
		if not is_matching_ingredients:
			continue
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
