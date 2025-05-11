class_name Inventory extends ItemList

@export var max_item_count := 24 ## Max number of slots in the inventory
@export var blank_icon : Texture2D ## Icon to be used when no item is in the slot (50x50)
@export var player : Player ## The player who the inventory will effect

var drag_item_scene = preload("res://UI/Inventory/drag_item_scene.tscn") # visual for item when dragging from inventory

var items : Array[Item] # List of the items in the inventory

func _ready() -> void:
	#for i in max_item_count: # Populate inventory with empty items
		#add_item(" ", blank_icon)
		#items.append(null) # TODO: use a different display method?
		
	item_clicked.connect(on_inventory_item_clicked)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_inventory"):
		toggle_inventory() # Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		close_inventory()

func toggle_inventory() -> void:
	visible = !visible # Flip visibility of the inventory

func close_inventory() -> void:
	visible = false

func add_inventory_item(item : Item) -> bool:
	if item == null or item.qty <= 0: # If invalid item or empty item
		return false
	
	var could_pickup : bool = add_stackable_item(item) # add to any existing stacks
	
	if item.qty <= 0: #if item was added to existing stacks
		return true
		
	for i in item_count: 
		if items[i] != null:
			continue
		
		items[i] = item
		set_item_icon(i, item.texture)
		
		if item.max_qty > 1:
			set_item_text(i, str(items[i].qty))
		
		return true
	return could_pickup

# Adds item to a stack or multiple stacks in inventory
func add_stackable_item(item : Item) -> bool:
	if item.max_qty < 2:
		return false
	
	var could_pickup : bool = false
	
	for i in item_count:
		if items[i] == null:
			print("Warning: Null item in Inventory")
			continue
		
		if items[i].ID != item.ID or items[i].qty >= items[i].max_qty:
			continue # If not a match or the item stack is full
		
		if items[i].qty + item.qty > items[i].max_qty: # Only add until stack is full
			var amount_to_remove : int = items[i].max_qty - items[i].qty
			
			items[i].qty = items[i].max_qty
			item.qty -= amount_to_remove
			
			could_pickup = true
			set_item_text(i, str(items[i].qty))
			continue
		
		#If the stack is a match
		items[i].qty += item.qty
		set_item_text(i, str(items[i].qty))
		return true
	
	if item_count >= max_item_count:
		print("Inventory is full")
		return could_pickup
	
	items.append(item.duplicate())
	add_item(str(item.qty), item.texture)
	item.qty = 0
	return true


func remove_inventory_item(index : int) -> void:
	if index < 0 or index >= item_count:
		return
	
	items.remove_at(index)
	remove_item(index)

func get_inventory_item(index : int) -> Item:
	if index < 0 or index >= item_count:
		return null
	
	return items[index]

func on_inventory_item_clicked(index : int, pos : Vector2, mouse_button_index : int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click. TODO: Make right click bring up interaction menu
		var item = get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		consume_inventory_item(item, index)
		
		#print("you dropped " + item.display_name + "items out of " + str(item.qty))
	if mouse_button_index == MOUSE_BUTTON_LEFT: # Left mouse pressed
		var item = get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		#TODO: make a drag_item based on item pressed
		drag_inventory_item(item, index)
		
		#close_inventory()

func drag_inventory_item(item : Item, index : int):
	var drag_item = drag_item_scene.instantiate()
		
	var da_item = item.duplicate()
	da_item.qty = 1
	item.qty -= 1
	set_item_text(index, str(item.qty))
	if item.qty < 1:
		remove_inventory_item(index)
	drag_item.item = da_item
	
	drag_item.texture = item.texture
	drag_item.inventory_ref = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
	get_parent().add_child(drag_item)

func consume_inventory_item(item : Item, index : int):
	player.update_status_effects(item.on_consume_effects, item.on_consume_message)
	if item.qty <= 1:
		remove_inventory_item(index)
	else:
		item.qty -= 1
		set_item_text(index, str(item.qty))
