class_name AlchemyTool extends Control


@export var item_gained_effect := preload("res://Effects/items_gained_effect_ui.tscn")
var recipes_folder_path := "res://Alchemy/Recipes/"
var tool_name := ""
var recipes : Array[Recipe]


signal item_produced(item: Item, recipe : Recipe) ## Sent when the item is completed and added to the inventory
signal close_inventory() ## Sent when the minigame window is opened, the inventory should be closed
signal open_inventory() ## Sent when minigame window is closed, the inventory should be opened

const MAX_ITEMS := 3 ## Max number of items that can be stored in the tool
var items : Array[Item] ## List of items in the tool
var num_items := 0 ## Number of items currently in the tool

var failed_craft : Recipe = preload("res://Alchemy/Recipes/failed_craft.tres") #ID for failed craft is 999

@onready var buttons := [$ToolIcon/ItemGrid/Button1,
$ToolIcon/ItemGrid/Button2,
$ToolIcon/ItemGrid/Button3] ## Reference to item buttons that represent each item

@onready var button_confirm := $ToolIcon/ItemGrid/ButtonConfirm
@onready var progress_bar := $ToolIcon/ProgressBar

var product : Item ## The item produced by the tool
var is_using := false ## State of whether a craft is currently active
var use_timer := 0.0 ## Time left in current craft
var cur_recipe : Recipe ## The recipe currently used in production


func _init() -> void:
	for i in MAX_ITEMS:
		buttons.append(null)
		items.append(null)
	


func set_recipes(folder_name : StringName):
	match folder_name:
		&"Cauldron": tool_name = "cauldron"
		&"M&P": tool_name = "m&p"
		&"Merger": tool_name = "merger"
	
	var dir = DirAccess.open(recipes_folder_path + folder_name + "/")
	if not dir:
		print("Error: No path")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var split = file_name.split(".")
		if split[-1] == "tres":
			var new_recipe : Recipe = load(recipes_folder_path + folder_name + "/" + file_name)
			if new_recipe:
				if new_recipe.tool_used != tool_name:
					print(new_recipe.product_item.display_name + " cannot be crafted using " + tool_name +
						", use " + new_recipe.tool_used + " instead")
				recipes.append(new_recipe)
		file_name = dir.get_next()


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
			
			var effect_instance = item_gained_effect.instantiate()
			
			effect_instance.add_item(product)
			effect_instance.scale = Vector2(1.3, 1.3)
			add_child(effect_instance)
			
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
	#TODO: Add minigame / qte's for crafting?

func open_minigame(item: Item):
	close_inventory.emit()
	%MortarPestleMinigame.open_window(item) #FIXME: Not generic

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


func remove_item(index: int):
	buttons[index].texture_normal = global.blank_texture
	buttons[index].disabled = true
	items[index] = null
	num_items -= 1
	
	if num_items < 1:
		button_confirm.disabled = true

func _on_button_1_pressed() -> void:
	item_produced.emit(items[0])
	remove_item(0)

func _on_button_2_pressed() -> void:
	item_produced.emit(items[1])
	remove_item(1)

func _on_button_3_pressed() -> void:
	item_produced.emit(items[2])
	remove_item(2)

func _on_minigame_item_produced(item: Item, recipe: Recipe = null) -> void:
	item_produced.emit(item, recipe)

func _on_open_inventory() -> void:
	open_inventory.emit()
