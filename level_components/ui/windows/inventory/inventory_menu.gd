## Menu that represents the inventory of a character.
extends UIWindow

## Max number of slots in the inventory.
@export var max_item_count := 24 
## Reference to the currently used inventory. Sets the default referenced character as Player.
#@onready var character_ref : Character = Global.focused_node
## visual for item when dragging from inventory
var drag_item_scene := preload("./drag_item_scene.tscn") 
## Reference to the Hotbar UI
@onready var hotbar_ref := $"../../../HUDLayer/Hotbar"
## Reference to the Tool Wheel UI
@onready var toolwheel_ref := $"../../../HUDLayer/ToolWheel"
## Reference to the Recipe List UI
@onready var recipe_list_ref := $"../../RightWindows/RecipeList"
## Reference to Cauldron Minigame UI
@onready var minigame_cauldron_ref := $"../../../MinigameLayer/MinigameCauldron"
## Reference to Mortar Pestle Minigame UI
@onready var minigame_mp_ref := $"../../../MinigameLayer/MinigameMP"
## (UNUSED)Item that is currently selected in the inventory (not dragged)
#var selected_item : Item 

## Sets references, initializes variables in references, and connects signals
func _ready() -> void:
	window_mode = &"menu"
	%Cauldron.minigame_ref = minigame_cauldron_ref
	%Cauldron.minigame_ref.recipes = %Cauldron.recipes
	%Cauldron.inventory_menu_ref = self
	minigame_cauldron_ref.tool_ref = %Cauldron
	%MortarPestle.minigame_ref = minigame_mp_ref
	%MortarPestle.minigame_ref.recipes = %MortarPestle.recipes
	%MortarPestle.inventory_menu_ref = self
	minigame_mp_ref.tool_ref = %MortarPestle
	%Merger.inventory_menu_ref = self

## Controls functions executed when input actions are pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_window() ## Toggles whether the inventory is displayed or not

## Toggles the visibility of the window. If it is close, it will open and vice versa.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Closes the window and removes it from the active window group.
func close_window() -> void:
	if Global.mode == window_mode:
		Global.left_window = null
		if not Global.right_window and not Global.center_window:
			Global.mode = &"default"
		visible = false
	
	elif Global.mode == &"dropper":
		Global.left_window = null
		Global.mode = &"default" ## There should be no other UI windows open
		visible = false
	
	elif Global.mode == &"menu": ## Minigame in progress, do not change groups.
		visible = false
	
	return_alchemy_items()

## Opens the window and adds it to the active window group.
## Inventory reference should be set before the window is opened.
func open_window() -> bool:
	if Global.left_window or Global.center_window or visible:
		return false ## Do not open, there is already a window open in the area.
	if not Global.focused_node:
		print("ERROR: No character reference to display inventory")
		return false ## Cannot configure inventory menu without an inventory reference.
	if Global.mode == &"default":
		Global.mode = window_mode
	if Global.mode == window_mode:
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D["parameters/switch_to_clip"] = "open"
		update_window()
		Global.left_window = self
		%WindowName.text = "Inventory and Crafting"
		visible = true
		return true
	elif Global.mode == &"dropper":
		$AudioStreamPlayer2D.play()
		update_window()
		Global.left_window = self
		%WindowName.text = "Select an Item for the Dropper"
		visible = true
		return true
	return false

## Clear the inventory item list, then re-initialize the item list with the items
## in the currently referenced character's inventory.
func update_window():
	%ItemList.clear()
	var items : Array[Item] = Global.focused_node.inventory.items
	
	for i in items.size():
		if items[i] == null:
			continue
		if items[i]:
			%ItemList.add_item(generate_item_text(items[i]), items[i].texture)

## Goes through each slot in the alchemy tools in the inventory and
## returns the items back to the inventory.
func return_alchemy_items() -> void:
	for i in range(3):
		Global.focused_node.inventory.add_item(%Cauldron.items[i])
		%Cauldron.remove_item(i)
		Global.focused_node.inventory.add_item(%Merger.items[i])
		%Merger.remove_item(i)
	Global.focused_node.inventory.add_item(%MortarPestle.items[0])
	%MortarPestle.remove_item(0)

## Adds an item to the character's inventory, then updates the menu.
func add_inventory_item(item : Item) -> bool:
	if not item or not Global.focused_node.inventory.add_item(item):
		return false
	update_window()
	return true

## Adds an item that was produced through crafting to the inventory
## And add the recipe to the known recipe book, if not already.
func add_produced_item(item : Item, recipe : Recipe = null) -> void:
	if item:
		add_inventory_item(item)
	if recipe != null:
		Global.focused_node.learn_recipe(recipe, true)
		
		## Update the recipe list if already open.
		if recipe_list_ref.visible:
			var cur_recipe_item : Item = recipe_list_ref.cur_recipe_item
			recipe_list_ref.close_window()
			recipe_list_ref.open_window()
			if cur_recipe_item:
				recipe_list_ref.open_recipe_page(cur_recipe_item)

## Finds the first index of a given item in the inventory. returns -1 if not found.
func find_item(item : Item) -> int:
	var inventory_items : Array[Item] = Global.focused_node.inventory.items
	for i in range(inventory_items.size()):
		if inventory_items[i].id == item.id:
			return i
	return -1

## Sets the text of the item as displayed in the Inventory UI.
func generate_item_text(item: Item) -> String:
	var text := ""
	if item.max_qty > 1:
		text += str(item.qty) + " | "
	text += item.display_name + " | " + item.description
	return text

## Removes the slot/stack of the inventory item at the given index in the inventory.
func remove_inventory_slot(index : int) -> void:
	if index < 0 or index >= %ItemList.item_count:
		return
	
	Global.focused_node.inventory.items.remove_at(index)
	%ItemList.remove_item(index)

## Removes the list of inventory items from the inventory.
## If isRemoveingStacks is true, removes any stack that contains any item in the array of items.
func remove_inventory_items(items_removing : Array[Item], qtys : Array[int], isRemovingStacks : bool = false) -> bool: ## Returns false if not enough items are found for each item in the inventory
	if not Global.focused_node.inventory.remove_items(items_removing, qtys, isRemovingStacks):
		return false
	update_window()
	return true

## Removes the given quantity of the item from the inventory.
## If [param isRemovingStacks] is true, removes any stack that contains the item in the inventory.
func remove_inventory_item(item_removing : Item, qty : int, isRemovingStacks : bool = false) -> bool: ## Returns false if not enough items are found for each item in the inventory
	if not Global.focused_node.inventory.remove_items([item_removing], [qty], isRemovingStacks):
		return false
	update_window()
	return true

## Determines what to do when the item is clicked on.
func _on_inventory_item_clicked(index : int, _pos : Vector2, mouse_button_index : int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click.
		var item = Global.focused_node.inventory.get_inventory_item(index)
		
		if item == null:
			print("WARNING: No items found")
			return
		
		match Global.mode:
			&"menu": use_item(item, index)
			&"dropper": pass
		
		#print("you dropped " + str(item.qty) + item.display_name + " out of " + stritems[index].qty))
	if mouse_button_index == MOUSE_BUTTON_LEFT: # Left mouse pressed
		var item = Global.focused_node.inventory.get_inventory_item(index)
		
		if item == null:
			print("WARNING: No items found")
			return
		
		match Global.mode:
			&"menu": drag_item(item, index)
			&"dropper": _set_dropper_item(item)
		
		#close_inventory()

## Moves the item relative to the mouse position.
func drag_item(item : Item, index : int):
	var drag_item_instance = drag_item_scene.instantiate()
		
	var selected_item = item.duplicate()
	selected_item.qty = 1
	item.qty -= 1
	%ItemList.set_item_text(index, generate_item_text(item))
	if item.qty < 1:
		remove_inventory_slot(index)
	drag_item_instance.item = selected_item
	
	drag_item_instance.texture = item.texture
	drag_item_instance.inventory_menu = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
	get_parent().add_child(drag_item_instance)

## Determines how to use the item in the inventory.
func use_item(item: Item, index : int) -> void:
	## Potions are ID 500-750. Splash potions are 750+. Recipe books are 1000+.
	#if item.type == "Potion" or item.type == "Book":
	consume_item(item, index)
	#else:
		#sample_item(item)

## Uses the given item without reducing the count of the item.
func sample_item(item) -> void:
	if not $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the sampling is disabled
		return
	Global.focused_node.update_status_effects(item.on_consume_effects, item.on_consume_message)
	$CooldownInteract.start()

## Uses the given item and reduces its count in the inventory.
func consume_item(item : Item, index : int) -> void:
	if not $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the consuming is disabled
		return
		
	Global.focused_node.update_status_effects(item.on_consume_effects, item.on_consume_message)
	
	match item.use_sound:
		"eat":
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = &"eat"
		"drink":
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = &"drink"
		"read":
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = &"read"
		"equip":
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = &"equip"
	
	if item.type == "Book": ## If item is a book
		Global.focused_node.read_book(item)
		if recipe_list_ref.visible:
			recipe_list_ref.close_window()
			recipe_list_ref.open_window()
				
		if not item.on_consume_effects: ## If there were no effects, display book message anyways.
			Global.focused_node.update_status_message(item.on_consume_message)
	
	if item.id not in Global.focused_node.items_used.keys():
		Global.focused_node.items_used[item.id] = 1
	else:
		Global.focused_node.items_used[item.id] += 1
	
	if item.id not in UserVariables.items_used.keys():
		UserVariables.items_used[item.id] = 1
	else:
		UserVariables.items_used[item.id] += 1
	
	$CooldownInteract.start()
	
	if item.qty <= 1:
		remove_inventory_slot(index)
	else:
		item.qty -= 1
		%ItemList.set_item_text(index, generate_item_text(item))
	
	## Check item for if it should be removed from the hotbar
	if hotbar_ref.has_item(item):
		var has_more_items := false
		for cur_item in Global.focused_node.inventory.items:
			if cur_item.id != item.id:
				continue
			has_more_items = true
			break
		
		if not has_more_items:
			hotbar_ref.remove_hotbar_item(item)

## Adds item from the hotbar to the inventory.
func _on_hotbar_add_inventory_item(item: Item) -> void:
	Global.focused_node.inventory.add_item(item)

## Uses the item on the hotbar and removes it from the inventory.
## @deprecated
func use_hotbar_item(item : Item):
	use_item(item, Global.focused_node.inventory.get_item_index(item))
	#var has_more_items := false
	#var is_consumed := false
	#var num_items := len(character_ref.inventory.items)
	#
	#for i in num_items:
		### If item is removed from inventory, prevents accessing invalid index of inventory
		#if num_items <= i: 
			#break
		#var cur_item = character_ref.inventory.items[i]
		#if cur_item.id != item.id:
			#continue
		#if not is_consumed:
			#character_ref.update_status_effects(cur_item.on_consume_effects, cur_item.on_consume_message)
			#
			#if item.type == "Book":
				#for recipe in item.recipes:
					#character_ref.learn_recipe(recipe)
				#if not item.on_consume_effects: ## If there were no effects, display book message anyways.
					#character_ref.update_status_message(item.on_consume_message)
			#
			#is_consumed = true
			#if cur_item.qty <= 1:
				#remove_inventory_slot(i)
				#num_items -= 1
			#else:
				#cur_item.qty -= 1
				#%ItemList.set_item_text(i, generate_item_text(cur_item))
				#has_more_items = true
		#else:
			#has_more_items = true
	
	if item.qty == 0: # Remove item from hotbar if no more of this item is in inventory slot
		hotbar_ref.remove_hotbar_item(item)

## Triggers when the input action is pressed to use the item in the given hotbar slot.\
## Uses the given item on the hotbar and reduces its count.
func _on_hotbar_use_inventory_item(item: Item) -> void:
	use_hotbar_item(item) #FIXME: Items that are not potions should either be sampled or not allowed on the hotbar

## Triggers when the item in the dropper item is set, and the currently active tool.
func _on_tool_wheel_set_dropper_item() -> void:
	if visible:
		close_window()
	Global.mode = "dropper"
	open_window()

## Sets the dropper item in the tool wheel.
func _set_dropper_item(item: Item):
	toolwheel_ref.dropper_item = item
	close_window()

## Triggers when the button used to close the window is pressed, which closes the window.
func _on_button_close_pressed() -> void:
	close_window()
