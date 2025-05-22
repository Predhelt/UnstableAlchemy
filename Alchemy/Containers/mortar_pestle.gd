extends Control

signal item_produced(recipe: Recipe) ## Signal sent when the item is completed brewing and added to the inventory

var inventory_ref ## Reference to the connected inventory for putting completed brews

const MAX_ITEMS := 3 ## Max number of items that can be stored in the cauldron
var items : Array[Item] ## List of items in the cauldron
var num_items := 0 ## Number of items currently in the cauldron

var failed_craft := preload("res://Items/Products/failed_potion_red.tres")
var cur_recipe : Recipe

@onready var buttons := [$TextureRect/ItemGrid/Button1,
$TextureRect/ItemGrid/Button2,
$TextureRect/ItemGrid/Button3] ## Reference to item buttons that represent each item

@onready var button_confirm := $TextureRect/ItemGrid/ButtonConfirm
@onready var progress_bar := $TextureRect/ProgressBar

var product : Item ## The item produced by the craft
var is_using := false ## State of whether a craft is currently active
var use_timer := 0.0 ## Time left in current craft

@export var recipes : Array[MortarPestleRecipe] #TODO: Use one uniform data type for all recipes or be able to convert recipe types
var mp_recipes = {} ## Recipes for each item that can be produced in the mortar & pestle


func _init() -> void:
	for i in MAX_ITEMS:
		buttons.append(null)
		items.append(null)

func _ready() -> void:
	for recipe in recipes:
		mp_recipes[recipe.ingredient_id] = [recipe.result_item, 
			recipe.result_item_amount, recipe.result_craft_time]

func _process(delta: float) -> void:
	if global.is_dragging:
		scale = Vector2(1.1, 1.1) #TODO: Set icon to "open" icon when hovered over while dragging
	else:
		scale = Vector2(1, 1)
	
	if is_using:
		if use_timer > 0:
			use_timer -= delta
			progress_bar.value += delta
		else:
			print(str(product.qty) + " of item " + product.display_name + " added to inventory from successful M&P")
			inventory_ref.add_inventory_item(product)
			
			#TODO: CREATE RECIPE TO SEND TO THE RECIPE LIST (COPY FOR CAULDRON)
			var recipe := Recipe.new()
			recipe.product_item = product
			recipe.ingredients
			recipe.tool_used = "m&p"
			item_produced.emit(recipe)
			
			progress_bar.visible = false
			is_using = false


func add_item(item: Item) -> bool:
	if is_using:
		print("Please wait for M&P to finish")
		return false
	if num_items >= MAX_ITEMS:
		print("M&P already full")
		return false

	for i in MAX_ITEMS:
		if not items[i]:
			items[i] = item
			buttons[i].texture_normal = item.texture
			buttons[i].disabled = false
			button_confirm.disabled = false
			num_items += 1
			return true
	
	print("Error: should never happen, if full of items, should have returned earlier")
	return false


func _on_button_confirm_pressed() -> void:
	if num_items <= 0 or num_items > MAX_ITEMS:
		print("Wrong number of items, button should be disabled")
		return
	use_item()

func use_item():
	# Find first item in queue to start using in the mortar and pestle
	var use_item : Item
	for i in MAX_ITEMS:
		if items[i]:
			use_item = items[i]
			remove_item(i)
			break
	
	var item_results = [failed_craft, 1, 2] #ID for failed craft is 999
	if use_item in mp_recipes:
		item_results = mp_recipes[use_ID]
	
	product = item_results[0]
	if not product:
		return
	product = product.duplicate()
	product.qty = item_results[1]
	use_timer = item_results[2]
	
	progress_bar.value = 0
	progress_bar.max_value = use_timer
	progress_bar.visible = true
	is_using = true


func _on_button_1_pressed() -> void:
	inventory_ref.add_inventory_item(items[0])
	remove_item(0)

func _on_button_2_pressed() -> void:
	inventory_ref.add_inventory_item(items[1])
	remove_item(1)

func _on_button_3_pressed() -> void:
	inventory_ref.add_inventory_item(items[2])
	remove_item(2)

func remove_item(index: int):
	buttons[index].texture_normal = global.blank_texture
	buttons[index].disabled = true
	items[index] = null
	num_items -= 1
	
	if num_items < 1:
		button_confirm.disabled = true
