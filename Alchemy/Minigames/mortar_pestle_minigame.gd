extends Panel

signal item_produced(item: Item, recipe : Recipe) ## Signal sent when the item is completed and added to the inventory
signal open_inventory()

@export var item_gained_effect := preload("res://Effects/items_gained_effect_ui.tscn")
@onready var tick_value : float = float(%ProgressSlider.max_value)/(%ProgressSlider.tick_count-1) ##The value of each tick
var recipes : Array[Recipe] ## List of recipes using the associated tool

var cur_craft_ingredient : Item ## Item used in the recipe
var cur_craft_procedure : Procedure ## List of input actions of the current craft attempt
var is_crafting := false ## Tracks if the minigame is currently active

#TODO: Determine if craft difficulty could be set dynamically
var input_window_ratio := 0.8 ## The window of acceptable input for each tick. Smaller values means tighter timing
var failed_craft : Recipe = preload("res://Alchemy/Recipes/failed_craft.tres") ##ID for failed craft is 999

func _process(delta: float) -> void:
	if is_crafting:
		if %ProgressSlider.value < %ProgressSlider.max_value:
			%ProgressSlider.value += delta
		else:
			is_crafting = false
			check_results()

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
		if len(recipe.ingredients) != 1:
			continue
		if recipe.ingredients[0].id == cur_craft_ingredient.id:
			if recipe.procedure.compare(cur_craft_procedure):
				return recipe
	return null


func _input(event: InputEvent) -> void:
	if global.mode != &"craft_minigame":
		return # No input events should catch on wrong mode
	if is_crafting:
		#if event.is_action_pressed("minigame_grind"):
			#set_input_action("equipment", 0, $ButtonGrind.icon)
		#elif event.is_action_pressed("minigame_crush"):
			#set_input_action("equipment", 1, $ButtonCrush.icon)
		pass
	if event.is_action_pressed("ui_cancel"):
		close_window()

func open_window(item: Item):
	# Reset the window before opening
	cur_craft_ingredient = item
	cur_craft_procedure = Procedure.new()
	$ButtonCrush.disabled = true
	$ButtonGrind.disabled = true
	$ButtonStart.disabled = false
	%ProgressSlider.value = 0
	%ItemIcon.texture = item.texture
	for tb in $HBoxContainer.get_children():
		tb.texture = global.blank_texture
	
	visible = true
	global.mode = &"craft_minigame"

func close_window():
	is_crafting = false
	visible = false
	open_inventory.emit() # Mode gets set by inventory


func set_input_action(type: String, id: int, icon: Texture2D):
	var nearest_tick = _get_nearest_tick()
	
	if nearest_tick < 0:
		return
	
	var input_action := ProcedureInputAction.new()
	input_action.type = type
	input_action.id = id
	if not cur_craft_procedure.input_actions[nearest_tick]:
		cur_craft_procedure.input_actions[nearest_tick] = input_action
		$HBoxContainer.get_children()[nearest_tick].texture = icon
		


func _get_nearest_tick() -> int:
	var nearest_tick := -1
	
	var tick_mod : float = fmod((%ProgressSlider.value + (tick_value / 2.0)), tick_value)
	tick_mod = tick_mod / tick_value
	var lower_bound := (1-input_window_ratio)/2
	var upper_bound := input_window_ratio+((1-input_window_ratio)/2)
	if tick_mod < upper_bound and tick_mod > lower_bound:
		nearest_tick = int((%ProgressSlider.value + (tick_value / 2.0)) / tick_value) - 1
	else: # Bad input. TODO: Determine if the input for the tick should be locked on bad input.
		pass
	
	return nearest_tick





func begin_minigame():
	$ButtonCrush.disabled = false
	$ButtonGrind.disabled = false
	$ButtonStart.disabled = true
	
	#TODO: Add delay before slider begins moving and countdown.
	
	%ProgressSlider.value = 0
	is_crafting = true


func _on_button_start_pressed() -> void:
	begin_minigame()


func _on_button_grind_pressed() -> void:
	set_input_action("equipment", 0, $ButtonGrind.icon)


func _on_button_crush_pressed() -> void:
	set_input_action("equipment", 1, $ButtonCrush.icon)
