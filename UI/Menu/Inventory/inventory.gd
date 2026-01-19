class_name Inventory extends Panel

### DEPRECATED: Sent to the player to update their status effects when an item in inventory is consumed
signal update_status_effects(on_consume_effects : Array[StatusEffect], on_consume_message : String)

## Max number of slots in the inventory
@export var max_item_count := 24 
## visual for item when dragging from inventory
var drag_item_scene := preload("res://UI/Menu/Inventory/drag_item_scene.tscn") 
## Reference to the Hotbar UI
@onready var hotbar_ref := %Hotbar
## Reference to the Tool Wheel UI
@onready var toolwheel_ref := %ToolWheel
## List of items in the inventory
@export var items : Array[Item]
## Item that is currently selected in the inventory (not dragged)
#var selected_item : Item 

## Sets references, initializes variables in references, and connects signals
func _ready() -> void:
	%ItemList.item_clicked.connect(on_inventory_item_clicked)
	%Cauldron.minigame_ref = %MinigameCauldron
	%Cauldron.minigame_ref.recipes = %Cauldron.recipes
	%MinigameCauldron.tool_ref = %Cauldron
	%MortarPestle.minigame_ref = %MinigameMP
	%MortarPestle.minigame_ref.recipes = %MortarPestle.recipes
	%MinigameMP.tool_ref = %MortarPestle
	
	for i in len(items):
		if items[i]:
			%ItemList.add_item(generate_item_text(items[i]), items[i].texture)

## Controls functions executed when input actions are pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_window() ## Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		close_window()
	#if event.is_action_pressed("recipe_book"):
		#close_window()

## Toggles the visibility of the window. If it is close, it will opena and vice versa.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Closes the window and removes it from the active window group.
func close_window() -> void:
	if global.mode == &"menu":
		remove_from_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		if get_tree().get_nodes_in_group("menu").is_empty():
			global.mode = &"default"
		visible = false
	
	elif global.mode == &"dropper":
		global.mode = &"default"
		visible = false

## Opens the window and adds it to the active window group.
func open_window() -> void:
	if global.mode == &"default" or global.mode == &"menu":
		global.mode = &"menu"
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		%WindowName.text = "Inventory and Crafting"
		visible = true
	elif global.mode == &"dropper":
		%WindowName.text = "Select an Item for the Dropper"
		visible = true

## Adds an item to the inventory.
func add_inventory_item(item : Item) -> bool:
	if item == null or item.qty <= 0: # If invalid item or empty item
		return false
	
	var could_pickup : bool = add_stackable_item(item) # add to any existing stacks
	
	if item.qty <= 0: #if item was added to existing stacks
		return true
		
	for i in %ItemList.item_count: 
		if items[i] != null:
			continue
		
		items[i] = item
		%ItemList.set_item_icon(i, item.texture)
		
		%ItemList.set_item_text(i, generate_item_text(items[i]))
		
		return true
	return could_pickup

# Adds item to a stack/slot or multiple stacks in inventory
func add_stackable_item(item : Item) -> bool:
	if item.max_qty < 2:
		return false # not stackable
	
	var could_pickup : bool = false
	
	for i in %ItemList.item_count:
		if items[i] == null:
			print("Warning: Null item in Inventory")
			continue
		
		if items[i].id != item.id or items[i].qty >= items[i].max_qty:
			continue # If not a match or the item stack is full
		
		if items[i].qty + item.qty > items[i].max_qty: # Only add until stack is full
			var amount_to_remove : int = items[i].max_qty - items[i].qty
			
			items[i].qty = items[i].max_qty
			item.qty -= amount_to_remove
			
			#could_pickup = true
			%ItemList.set_item_text(i, generate_item_text(items[i]))
			return true
		
		#If the stack is a match
		items[i].qty += item.qty
		item.qty = 0
		%ItemList.set_item_text(i, generate_item_text(items[i]))
		return true
	
	if %ItemList.item_count >= max_item_count:
		print("Inventory is full")
		return could_pickup
	
	items.append(item.duplicate())
	%ItemList.add_item(generate_item_text(item), item.texture)
	item.qty = 0
	return true

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
	
	items.remove_at(index)
	%ItemList.remove_item(index)

## Removes the list of inventory items from the inventory.
## If isRemoveingStacks is true, removes any stack that contains any item in the array of items.
func remove_inventory_items(items_removing : Array[Item], qtys : Array[int], isRemovingStacks : bool = false) -> bool: ## Returns false if not enough items are found for each item in the inventory
	## Phase 1: Check to see if there are enough of each item. If removing stacks, ignore phase 1
	var inventory_item_infos : Dictionary = {} ## Key : index, Value : id of items in inventory
	
	if not isRemovingStacks:
		
		inventory_item_infos = has_inventory_items(items_removing, qtys)
	
		if inventory_item_infos == {}:
			return false
	
		## Phase 2: remove items from inventory
		var inventory_indices : Array = inventory_item_infos.keys()
		inventory_indices.sort()
		inventory_indices.reverse() ## Descending order because the size will change if an item is removed from the inventory item list
		
		for inventory_index in inventory_indices:
			for cur_item_index in range(items_removing.size()):
				var cur_item = items_removing[cur_item_index]
				## Find matching IDs
				if inventory_item_infos[inventory_index] == cur_item.id:
					var cur_qty = qtys[cur_item_index]
					if cur_qty < 0:
						print("error, trying to remove negative quantity of" + cur_item.display_name)
					if cur_qty == 0: ## Nothing to remove, skip to next index.
						break
					## Remove item qty from index in inventory
					var inventory_item = items[inventory_index]
					if cur_qty < inventory_item.qty:
						inventory_item.qty -= cur_qty ## Only remove some if amount is less than the stack
						qtys[cur_item_index] = 0
						break
					else:
						remove_inventory_slot(inventory_index)
						qtys[cur_item_index] -= inventory_item.qty
		
		## Confirm that all requested items have been removed from inventory
		var sum : int = 0
		for qty in qtys:
			sum += qty
		if sum > 0:
			return false
		else:
			return true
	
	##  If removing all instances of items:
	for i in range(items.size()-1,0): # Descending so that decreasing array size does not cause out of bound error
		if i >= items.size(): # Index can be greater than size if multiple items are removed from list
			continue
		for item_removing in items_removing:
			if items[i].id == item_removing.id:
				remove_inventory_slot(i)
	return true

## Checks if the inventory has all items and their appropriate amounts.
## Returns a dictionary where Keys are indices and Values are ids of the items in inventory.
func has_inventory_items(items_checking : Array[Item], qtys : Array[int]) -> Dictionary:
	var found_items : Dictionary ## Key : index, Value : id of items in inventory
	
	for i in range(items_checking.size()):
		var temp_qty : int = qtys[i]
		for j in range(items.size()-1, -1, -1): # Descending order, to remove the later elements first.
			if items_checking[i].id == items[j].id:
				found_items[j] = items_checking[i].id
				if temp_qty <= items[j].qty:
					temp_qty = 0
					break
				else:
					temp_qty -= items[j].qty
		if temp_qty > 0:
			return {}
	
	return found_items

## Gets the list of items at the current index in the list of items in the inventory.
func get_inventory_item(index : int) -> Item:
	if index < 0 or index >= %ItemList.item_count:
		return null
	
	return items[index]

## Determines what to do when the item is clicked on.
func on_inventory_item_clicked(index : int, _pos : Vector2, mouse_button_index : int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click.
		var item = get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		match global.mode:
			&"menu": use_item(item, index)
			&"dropper": pass
		
		#print("you dropped " + str(item.qty) + item.display_name + " out of " + stritems[index].qty))
	if mouse_button_index == MOUSE_BUTTON_LEFT: # Left mouse pressed
		var item = get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		match global.mode:
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
	drag_item_instance.inventory_ref = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
	get_parent().add_child(drag_item_instance)

## Determines how to use the item in the inventory.
func use_item(item: Item, index : int):
	var is_potion := item.id >= 500 and item.id < 750 # Potions are ID 500-750. Splash potions are 750+
	if not is_potion:
		sample_item(item)
	else:
		consume_item(item, index)

## Uses the given item without reducing the count of the item.
func sample_item(item):
	if $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the sampling is disabled
		%Player.update_status_effects(item.on_consume_effects, item.on_consume_message)
		$CooldownInteract.start()

## Uses the given item and reduces its count in the inventory.
func consume_item(item : Item, index : int):
	if $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the consuming is disabled
		%Player.update_status_effects(item.on_consume_effects, item.on_consume_message)
		$CooldownInteract.start()
	
	if item.qty <= 1:
		remove_inventory_slot(index)
	else:
		item.qty -= 1
		%ItemList.set_item_text(index, generate_item_text(item))
	
	## Check item for if it should be removed from the hotbar
	if hotbar_ref.has_item(item):
		var has_more_items := false
		for cur_item in items:
			if cur_item.id != item.id:
				continue
			has_more_items = true
			break
		
		if not has_more_items:
			hotbar_ref.remove_hotbar_item(item)

## 
func _on_hotbar_add_inventory_item(item: Item) -> void:
	add_inventory_item(item)

## Uses the item on the hotbar and removes it from the inventory.
func consume_hotbar_item(item : Item):
	var has_more_items := false
	var is_consumed := false
	var num_items := len(items)
	
	for i in num_items:
		if num_items <= i: # If item is removed from inventory, will prevent accessing invalid index of inventory
			break
		var cur_item = items[i]
		if cur_item.id != item.id:
			continue
		if not is_consumed:
			update_status_effects.emit(cur_item.on_consume_effects, cur_item.on_consume_message)
			is_consumed = true
			if cur_item.qty <= 1:
				remove_inventory_slot(i)
				num_items -= 1
			else:
				cur_item.qty -= 1
				%ItemList.set_item_text(i, generate_item_text(cur_item))
				has_more_items = true
		else:
			has_more_items = true
	
	if not has_more_items: # Remove item from hotbar if no more of this item is in inventory
		hotbar_ref.remove_hotbar_item(item)

## Triggers when the input action is pressed to use the item in the given hotbar slot.\
## Uses the given item on the hotbar and reduces its count.
func _on_hotbar_consume_inventory_item(item: Item) -> void:
	consume_hotbar_item(item) #FIXME: Items that are not potions should either be sampled or not allowed on the hotbar

## Triggers when the item in the dropper item is set, and the currently active tool.
func _on_tool_wheel_set_dropper_item() -> void:
	global.mode = "dropper"
	open_window()

## Sets the dropper item in the tool wheel.
func _set_dropper_item(item: Item):
	toolwheel_ref.dropper_item = item
	close_window()

## Treggers when a crafting minigame is completed and an item is added to the inventory.
func _on_item_produced(item: Item, recipe: Recipe = null) -> void:
	if item:
		add_inventory_item(item)
	if recipe != null:
		%Player.learn_recipe(recipe)

## Triggers when the inventory window is opened.
## Adds the inventory to the window group and updates the window title.
func _on_open_inventory() -> void:
	global.mode = &"menu"
	add_to_group("menu")
	%WindowName.text = "Inventory and Crafting"
	visible = true

## Triggers when the inventory window is closed.
## Removes the inventory from the window group and hides the window.
func _on_close_inventory() -> void:
	remove_from_group("menu")
	visible = false # Mode is set by the object that emitted the signal

## Triggers when the button used to close the window is pressed, which closes the window.
func _on_button_close_pressed() -> void:
	close_window()
