class_name AlchemyTool extends Control


@export var tool_name := ""
@export var recipes : Array[Recipe]

signal item_produced(item: Item, recipe : Recipe) ## Signal sent when the item is completed and added to the inventory

var inventory_ref ## Reference to the connected inventory for putting produced items

const MAX_ITEMS := 3 ## Max number of items that can be stored in the tool
var items : Array[Item] ## List of items in the tool
var num_items := 0 ## Number of items currently in the tool

var failed_craft : Recipe = preload("res://Alchemy/Recipes/failed_craft.tres") #ID for failed craft is 999

@onready var buttons := [$TextureRect/ItemGrid/Button1,
$TextureRect/ItemGrid/Button2,
$TextureRect/ItemGrid/Button3] ## Reference to item buttons that represent each item

@onready var button_confirm := $TextureRect/ItemGrid/ButtonConfirm
@onready var progress_bar := $TextureRect/ProgressBar

var product : Item ## The item produced by the tool
var is_using := false ## State of whether a craft is currently active
var use_timer := 0.0 ## Time left in current craft
var cur_recipe : Recipe ## The recipe currently used in production




func _init() -> void:
	for i in MAX_ITEMS:
		buttons.append(null)
		items.append(null)
	
	for i in len(recipes):
		if recipes[i].tool_used != tool_name:
			print(str(recipes[i].product_item) + " cannot be crafted using " + tool_name +
				", use " + recipes[i].tool_used + " instead")
			recipes.remove_at(i)


func _process(delta: float) -> void:
	if global.is_dragging:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
	
	if is_using:
		if use_timer > 0:
			use_timer -= delta
			progress_bar.value += delta
		else:
			print(str(product.qty) + " of item " + product.display_name + 
				" added to inventory from successful use of " + tool_name)
			
			item_produced.emit(product, cur_recipe)
			
			cur_recipe = null
			progress_bar.visible = false
			is_using = false


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
	
	print("Error: should never happen, if full of items, should have returned earlier")
	return false

func _on_button_confirm_pressed() -> void:
	if num_items <= 0 or num_items > MAX_ITEMS:
		print("Wrong number of items, button should be disabled")
		return
	_use_items()
	
func _use_items():
	pass # This function should be overridden

func begin_craft(result_recipe: Recipe):
	if not result_recipe.product_item:
		print("Error: No product item for recipe!")
		return
	
	cur_recipe = result_recipe
	
	product = result_recipe.product_item.duplicate()
	product.qty = result_recipe.product_item_amount
	use_timer = result_recipe.product_craft_time
	
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
