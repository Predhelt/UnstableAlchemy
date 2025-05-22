extends Control

signal item_produced(item : Item) ## Signal sent when the item is completed brewing and added to the inventory

var inventory_ref ## Reference to the connected inventory for putting completed brews

const MAX_ITEMS := 3 ## Max number of items that can be stored in the cauldron
var items : Array[Item] ## List of items in the cauldron
var num_items := 0 ## Number of items currently in the cauldron

var failed_craft := preload("res://Items/Products/failed_potion_red.tres")

@onready var buttons := [$TextureRect/ItemGrid/Button1,
$TextureRect/ItemGrid/Button2,
$TextureRect/ItemGrid/Button3] ## Reference to item buttons that represent each item

@onready var button_confirm := $TextureRect/ItemGrid/ButtonConfirm
@onready var progress_bar := $TextureRect/ProgressBar

var product : Item ## The item produced by the brew
var is_brewing := false ## State of whether a brew is currently active
var brew_timer := 0.0 ## Time left in current brew

@export var recipes : Array[CauldronRecipe]
var cauldron_recipes = {} ## Recipes for each item that can be produced in the cauldron


func _init() -> void:
	for i in MAX_ITEMS:
		buttons.append(null)
		items.append(null)

func _ready() -> void:
	for recipe in recipes:
		cauldron_recipes[recipe.ingredient_ids] = [recipe.result_item, 
			recipe.result_item_amount, recipe.result_craft_time]

func _process(delta: float) -> void:
	if global.is_dragging:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
	
	if is_brewing:
		if brew_timer > 0:
			brew_timer -= delta
			progress_bar.value += delta
		else: # Brew complete
			print(str(product.qty) + " of item " + product.display_name + " added to inventory from brew")
			inventory_ref.add_inventory_item(product)
			item_produced.emit(product)
			progress_bar.visible = false
			is_brewing = false


func add_item(item: Item) -> bool:
	if is_brewing:
		print("Please wait for cauldron to finish brewing")
		return false
	if num_items >= MAX_ITEMS:
		print("Cauldron already full")
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
	brew_items()

func brew_items():
	var brew_IDs : Array[int]
	for i in MAX_ITEMS:
		if items[i]:
			brew_IDs.append(items[i].ID)
			remove_item(i)
			
	brew_IDs.sort()
	
	var item_results = [failed_craft, 1, 2] #ID for failed brew is 999
	if brew_IDs in cauldron_recipes:
		item_results = cauldron_recipes[brew_IDs]
	
	product = item_results[0]
	if not product:
		return
	product = product.duplicate()
	product.qty = item_results[1]
	brew_timer = item_results[2]
	
	progress_bar.value = 0
	progress_bar.max_value = brew_timer
	progress_bar.visible = true
	is_brewing = true


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
