extends Panel

## DEPRECATED: Sent to the player to update their status effects when an item in inventory is consumed
signal update_status_effects(on_consume_effects : Array[StatusEffect], on_consume_message : String)


@export var max_item_count := 24 ## Max number of slots in the inventory

var drag_item_scene := preload("res://UI/Menu/Inventory/drag_item_scene.tscn") # visual for item when dragging from inventory
@onready var hotbar_ref := %Hotbar
@onready var toolwheel_ref := %ToolWheel

@export var items : Array[Item] # List of the items in the inventory
#var selected_item : Item # Item that is currently selected in the inventory (not dragged)

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_window() # Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		close_window()
	#if event.is_action_pressed("recipe_book"):
		#close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

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

# Adds item to a stack or multiple stacks in inventory
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

func generate_item_text(item: Item) -> String:
	var text := ""
	if item.max_qty > 1:
		text += str(item.qty) + " | "
	text += item.display_name + " | " + item.description
	return text


func remove_inventory_item(index : int) -> void:
	if index < 0 or index >= %ItemList.item_count:
		return
	
	items.remove_at(index)
	%ItemList.remove_item(index)

func get_inventory_item(index : int) -> Item:
	if index < 0 or index >= %ItemList.item_count:
		return null
	
	return items[index]


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

func drag_item(item : Item, index : int):
	var drag_item_instance = drag_item_scene.instantiate()
		
	var selected_item = item.duplicate()
	selected_item.qty = 1
	item.qty -= 1
	%ItemList.set_item_text(index, generate_item_text(item))
	if item.qty < 1:
		remove_inventory_item(index)
	drag_item_instance.item = selected_item
	
	drag_item_instance.texture = item.texture
	drag_item_instance.inventory_ref = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
	get_parent().add_child(drag_item_instance)


func use_item(item: Item, index : int):
	var is_potion := item.id >= 500 and item.id < 750 # Potions are ID 500-750. Splash potions are 750+
	if not is_potion:
		sample_item(item)
	else:
		consume_item(item, index)


func sample_item(item):
	if $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the sampling is disabled
		%Player.update_status_effects(item.on_consume_effects, item.on_consume_message)
		$CooldownInteract.start()

func consume_item(item : Item, index : int):
	if $CooldownInteract.is_stopped(): #NOTE: No visual indicator that the consuming is disabled
		%Player.update_status_effects(item.on_consume_effects, item.on_consume_message)
		$CooldownInteract.start()
	
	if item.qty <= 1:
		remove_inventory_item(index)
	else:
		item.qty -= 1
		%ItemList.set_item_text(index, generate_item_text(item))
	
	# Check item for if it should be removed from the hotbar
	if hotbar_ref.has_item(item):
		var has_more_items := false
		for cur_item in items:
			if cur_item.id != item.id:
				continue
			has_more_items = true
			break
		
		if not has_more_items:
			hotbar_ref.remove_hotbar_item(item)


func _on_hotbar_add_inventory_item(item: Item) -> void:
	add_inventory_item(item)

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
				remove_inventory_item(i)
				num_items -= 1
			else:
				cur_item.qty -= 1
				%ItemList.set_item_text(i, generate_item_text(cur_item))
				has_more_items = true
		else:
			has_more_items = true
	
	if not has_more_items: # Remove item from hotbar if no more of this item is in inventory
		hotbar_ref.remove_hotbar_item(item)

func _on_hotbar_consume_inventory_item(item: Item) -> void:
	consume_hotbar_item(item) #FIXME: Items that are not potions should either be sampled or not allowed on the hotbar


func _on_tool_wheel_set_dropper_item() -> void:
	global.mode = "dropper"
	open_window()

func _set_dropper_item(item: Item):
	toolwheel_ref.dropper_item = item
	close_window()


func _on_item_produced(item: Item, recipe: Recipe = null) -> void:
	if item:
		add_inventory_item(item)
	if recipe != null:
		%Player.learn_recipe(recipe)


func _on_open_inventory() -> void:
	global.mode = &"menu"
	add_to_group("menu")
	%WindowName.text = "Inventory and Crafting"
	visible = true


func _on_close_inventory() -> void:
	remove_from_group("menu")
	visible = false # Mode is set by the object that emitted the signal
	

func _on_button_close_pressed() -> void:
	close_window()
