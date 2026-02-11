## Logic and UI for the alchemy minigames. Used for Cauldron and Morter & Pestle.
## Most functionality is used in the Cauldron with some overlap.
class_name AlchemyMinigame extends UIWindow



### Signal connections are made in the inventory script
#
### Signal sent when the item is completed and added to the inventory.
#signal item_produced(item: Item, recipe : Recipe)
### Sends signal to the inventory to remove items when a craft minigame is completed
### and the ingredient items are consumed.
#signal item_removed(item: Item)
### Sends signal to open the inventory window.
#signal open_inventory()

## Reference to the current inventory that the minigame is using
var inventory_menu_ref
## Buttons used during the minigame. Set by inherited class.
var minigame_buttons : Array[Button]
## Reference to associated inventory tool. Set by Inventory.
var tool_ref : Control
## Visual effect that occurs when an item is added to the inventory.
@export var items_gained_effect := preload("res://art/effects/items_gained_effect_ui.tscn")
## UI Slider that displays the progress of the minigame.
@onready var slider := %MinigameProgressBar/ProgressSlider
##The value of each tick
@onready var tick_value : float = float(slider.max_value)/(slider.tick_count-1)
## List of recipes using the associated tool
var recipes : Array[Recipe]
## Item used in the recipe
var cur_craft_ingredients : Array[Item]
## List of input actions of the current craft attempt
var cur_craft_procedure : Procedure 
## Tracks if the minigame is currently active
var is_crafting := false
## Tracks the last item made to allow repeated crafts.
var last_item_produced : Item

#TODO: Determine if craft difficulty could be set dynamically by the player / circumstance
## The window of acceptable input for each tick.
## Smaller values means tighter timing / harder difficulty
@export var input_window_ratio := 0.5
## Recipe that represents the craft item when a craft attempt fails.
const FAILED_CRAFT : Recipe = preload("res://game_systems/alchemy/recipes/failed_craft.tres") #NOTE: ID for failed craft is 999

## Sets the window mode
func _init() -> void:
	window_mode = &"menu"

## Template: Sets how action keys should be handled in the relevant minigame.
func _input(_event: InputEvent) -> void:
	pass

## Template: Used to determine how the minigame should be set up when the window is opened.
## Already required by inherited UIWindow.s
#func open_window():
	#pass

## Sets the ingredient values.
func init_ingredients(ingredients : Array[Item]) -> void:
	for i in range(ingredients.size()):
		cur_craft_ingredients.append(ingredients[i])

## Closes the minigame window and ensures that the menu group is updated
func close_window():
	is_crafting = false
	visible = false
	cur_craft_ingredients.clear()
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = ""
	global.left_window = null ## This window shows up in the center of the screen
	if not global.center_window and not global.right_window:
		global.mode = &"default"
	elif global.center_window:
		global.mode = global.center_window.window_mode
	elif global.right_window:
		global.mode = global.right_window.window_mode

## Closes the current window and returns to the inventory menu.
func previous_window():
	is_crafting = false
	visible = false
	cur_craft_ingredients.clear()
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = ""
	global.left_window = null
	if not global.center_window and not global.right_window:
		global.mode = &"default"
	elif global.center_window:
		global.mode = global.center_window.window_mode
	elif global.right_window:
		global.mode = global.right_window.window_mode
	
	inventory_menu_ref.open_window()

## Initiates the start of an alchemy minigame.
func begin_minigame():
	%ButtonStart.disabled = true
	
	for i in len(cur_craft_ingredients): #NOTE: This works for Mortar and Pestle despite M&P not following this structure since there are only 2 buttons and 1 ingredient.
		if cur_craft_ingredients[i]:
			minigame_buttons[i].disabled = false
	minigame_buttons[-1].disabled = false
	
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = "Ready..."
	$StartupDelay.start()

## When the timer before the minigame begins finishes, start the crafting minigame.
func _on_startup_delay_timeout() -> void:
	slider.value = 0
	%MinigameProgressBar/ProgressSlider/StartupLabel.text = "Start!"
	is_crafting = true

## Upon completion of the minigame, check the user inputs and compare them to the
## list of crafting recipe to determine if the procedure and ingredients match. If not, 
## produces the failed item. If so, produces the matching item. Produced items
## are added to the character's inventory.
func check_results():
	var product_recipe := matching_recipe()
	var product_item : Item = FAILED_CRAFT.product_item.duplicate()
	if product_recipe:
		product_item = product_recipe.product_item.duplicate()
		product_item.qty = product_recipe.product_item_amount

	var effect_instance = items_gained_effect.instantiate()
			
	effect_instance.add_item(product_item)
	effect_instance.scale = Vector2(1.3, 1.3)
	tool_ref.add_child(effect_instance)
	
	for item : Item in cur_craft_ingredients:
		if item:
			inventory_menu_ref.remove_inventory_item(item, 1)
	inventory_menu_ref.add_produced_item(product_item, product_recipe)
	last_item_produced = product_item
	

## Goes through the list of recipes and returns a recipe that
## matches the current procedure, if any.
func matching_recipe() -> Recipe:
	for recipe in recipes:
		if len(recipe.ingredients) < 1 or len(recipe.ingredients) > 3:
			continue
		if recipe.procedure:
			if recipe.procedure.compare(cur_craft_procedure):
				return recipe
	return null

## Closes the current minigame window. Crafting items were already returned
## back to the inventory when the inventory window was closed.
func _on_button_close_pressed() -> void:
	close_window()

## Closes the current minigame window and opens the inventory window. Crafting items 
## were already returned back to the inventory when the inventory window was closed.
func _on_button_back_pressed() -> void:
	previous_window()
