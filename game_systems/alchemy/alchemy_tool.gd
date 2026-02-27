## Template class for alchemy tools to use to control how items are added to 
## their inventory tool and how the associated minigame functions
class_name AlchemyTool extends UIWindow

### Sent when the item is completed and added to the inventory
#signal item_produced(item: Item, recipe : Recipe)
### Sends signal to the inventory to remove items when a craft minigame is completed
### and the ingredient items are consumed.
##signal item_removed(item: Item)
### Sent when the minigame window is opened, the inventory should be closed
#signal close_inventory()


## Max number of items that can be stored in the tool
const MAX_ITEMS := 3
## The recipe information for a failed craft, used when no other recipe is a match after the crafting process.
## The Item ID for failed craft is 999
const FAILED_CRAFT : Recipe = preload("res://game_systems/alchemy/recipes/failed_craft.tres")
## Effect that occurs when the craft completes and an item is sent to the inventory.
## The effect displays when the inventory is opened.
@export var items_gained_effect := preload("res://art/effects/items_gained_effect_ui.tscn")
## Reference to the minigame scene. Gets set by inventory menu since it has proper scope
var minigame_ref : Control
## Reference to the inventory that the tool is using items from. Set by inventory menu.
var inventory_menu_ref
## Folder path used as a starting point to search for the list of related recipes
var recipes_folder_path := "res://game_systems/alchemy/recipes/"
## The name of the alchemy tool being used. Values can be cauldron, m&p, and merger.
var tool_name := ""
## The list of recipes related to the inherited script's alchemy tool
var recipes : Array[Recipe]
## List of items in the tool
var items : Array[Item]
## Number of items currently in the tool
var num_items := 0

## Reference to item buttons that represent each item used in the craft.
## These items are determined by the items in the corresponding alchemy
## tool container in the inventory page.
@onready var buttons := [$ToolIcon/ItemGrid/Button1,
$ToolIcon/ItemGrid/Button2,
$ToolIcon/ItemGrid/Button3] 
## Reference to the scene for the confirmation button
@onready var button_confirm := $ToolIcon/ItemGrid/ButtonConfirm
## Reference to the scene for the progress bar used in crafting animations without a minigame.
@onready var progress_bar := $ToolIcon/ProgressBar

## The item produced by the tool
var product : Item
## State of whether a craft is currently active
var is_using := false
## Time left in current craft
var use_timer := 0.0
## The recipe currently used in production
var cur_recipe : Recipe

## Makes the size of the buttons and items arrays to be
## the max number of items the tool can hold.
func _init() -> void:
	window_mode = &"menu"
	for i in MAX_ITEMS:
		buttons.append(null)
		items.append(null)
	

## Called in inherited function's _ready() procedure. The given folder_name is used
## to search the file directory for the recipes related to the alchemy tool being used
## by the child script. Each recipe is then added to the list of recipes
func set_recipes(recipe_tool : StringName):
	match recipe_tool:
		&"Cauldron": tool_name = "cauldron"
		&"Mortar & Pestle": tool_name = "mp"
		&"Merger": tool_name = "merger"
	
	var dir := DirAccess.open(recipes_folder_path + tool_name + "/")
	if not dir:
		print("Error: Recipe folder path not found")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var split = file_name.split(".")
		if split[-1] == "tres":
			var new_recipe : Recipe = load(recipes_folder_path + tool_name + "/" + file_name)
			new_recipe.tool_used = recipe_tool
			if new_recipe and new_recipe.id >= 0: ## Inactive Recipe is -1, do not include those
				recipes.append(new_recipe)
		file_name = dir.get_next()
	dir.list_dir_end()


func _process(delta: float) -> void:
	if Global.is_dragging:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
	## Used by alchemy tools that do not have alchemy minigame windows. Handles
	## the progress bar and timer to represent the time it takes to craft the product.
	## When the timer is completed, produces the item.
	if is_using:
		if use_timer > 0:
			use_timer -= delta
			progress_bar.value += delta
		else:
			print(str(product.qty) + " of item " + product.display_name + 
				" added to inventory from successful use of " + tool_name)
			
			var effect_instance = items_gained_effect.instantiate()
			
			effect_instance.add_item(product)
			effect_instance.scale = Vector2(1.3, 1.3)
			add_child(effect_instance)
			
			inventory_menu_ref.add_produced_item(product, cur_recipe)
			
			cur_recipe = null
			progress_bar.visible = false
			is_using = false

## Adds an item to the alchemy tool in the inventory.
func add_item(item: Item) -> bool:
	if is_using:
		print("Please wait for " + tool_name + " to finish")
		return false
	if num_items >= MAX_ITEMS:
		print(tool_name + " already full")
		return false

	for i in MAX_ITEMS:
		if not items[i]:
			items[i] = item
			buttons[i].texture_normal = item.texture
			buttons[i].disabled = false
			button_confirm.disabled = false
			num_items += 1
			return true
	
	print("Error: should never happen. if full of items, should have returned earlier")
	return false

## Called from inherited class. closes the inventory then opens the associated 
## minigame window using the items from the alchemy tool's container.
func open_minigame(mg_items: Array[Item]):
	minigame_ref.init_ingredients(mg_items)
	minigame_ref.inventory_menu_ref = inventory_menu_ref
	inventory_menu_ref.close_window()
	## Remove the items being used by the alchemy tool from the inventory
	## while the minigame is in progress
	var mg_qtys : Array[int] = []
	for i in mg_items.size():
		mg_qtys.append(1)
	if not inventory_menu_ref.remove_inventory_items(mg_items,mg_qtys):
		print("ERROR: Items not all removed from the inventory properly.")
	minigame_ref.open_window()

## For alchemy tools that do not have a separate minigame window.
func begin_craft(result_recipe: Recipe): #NOTE: Deprecate when merger is using minigame
	if not result_recipe.product_item:
		print("Error: No product item for recipe!")
		return
	
	for i in range(items.size()):
		if items[i]:
			remove_item(i)
	
	cur_recipe = result_recipe
	
	product = result_recipe.product_item.duplicate()
	product.qty = result_recipe.product_item_amount
	use_timer = result_recipe.product_craft_time
	
	progress_bar.value = 0
	progress_bar.max_value = use_timer
	progress_bar.visible = true
	is_using = true

## Removes an item from the alchemy tool and disables the slot at the given index.
func remove_item(index: int) -> void:
	if not items[index]:
		return
	buttons[index].texture_normal = Global.blank_texture
	buttons[index].disabled = true
	items[index] = null
	num_items -= 1
	
	if num_items < 1:
		button_confirm.disabled = true

## Abstract function that is implemented in inherited class. Called when Confirm button
## is pressed. This determines how the alchemy tool crafts using the given items.
## If an alchemy tool has a related minigame, use open_minigame in this function call.
func _use_items():
	pass # This function should be overridden

## When the confirmation button is pressed,
## sends the signal to use the relevant items in crafting.
func _on_button_confirm_pressed() -> void:
	if num_items <= 0 or num_items > MAX_ITEMS:
		print("Wrong number of items, button should be disabled")
		return
	_use_items()

## Removes item from the first slot in the alchemy tool when it is pressed on
## and puts the item back in the inventory.
func _on_button_1_pressed() -> void:
	inventory_menu_ref.add_produced_item(items[0])
	remove_item(0)

## Removes item from the second slot in the alchemy tool when it is pressed on
## and puts the item back in the inventory.
func _on_button_2_pressed() -> void:
	inventory_menu_ref.add_produced_item(items[1])
	remove_item(1)

## Removes item from the third slot in the alchemy tool when it is pressed on
## and puts the item back in the inventory.
func _on_button_3_pressed() -> void:
	inventory_menu_ref.add_produced_item(items[2])
	remove_item(2)
