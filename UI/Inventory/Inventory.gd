extends ItemList

## Sent to the player to update their status effects when an item in inventory is consumed
signal update_status_effects(on_consume_effects : Array[StatusEffect], on_consume_message : String)

@export var max_item_count := 24 ## Max number of slots in the inventory

var mode := "default"

var drag_item_scene := preload("res://UI/Inventory/drag_item_scene.tscn") # visual for item when dragging from inventory
@onready var hotbar_ref := %Hotbar
@onready var toolwheel_ref := %ToolWheel

var items : Array[Item] # List of theitems in the inventory

func _ready() -> void:		
	item_clicked.connect(on_inventory_item_clicked)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_inventory"):
		_toggle_inventory() # Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		_close_inventory()

func _toggle_inventory() -> void:
	if visible:
		_close_inventory()
	else:
		_open_inventory()

func _close_inventory() -> void:
	visible = false
	_set_mode("default")

func _open_inventory() -> void:
	visible = true

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
		
		set_item_text(i, generate_item_text(items[i]))
		
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
			
			items[i].qty =items[i].max_qty
			item.qty -= amount_to_remove
			
			could_pickup = true
			set_item_text(i, generate_item_text(items[i]))
			return true
		
		#If the stack is a match
		items[i].qty += item.qty
		item.qty = 0
		set_item_text(i, generate_item_text(items[i]))
		return true
	
	if item_count >= max_item_count:
		print("Inventory is full")
		return could_pickup
	
	items.append(item.duplicate())
	add_item(generate_item_text(item), item.texture)
	item.qty = 0
	return true

func generate_item_text(item: Item) -> String:
	var text := ""
	if item.max_qty > 1:
		text += str(item.qty) + " | "
	text += item.display_name + " | " + item.description
	return text


func remove_inventory_item(index : int) -> void:
	if index < 0 or index >= item_count:
		return
	
	items.remove_at(index)
	remove_item(index)

func get_inventory_item(index : int) -> Item:
	if index < 0 or index >= item_count:
		return null
	
	return items[index]


func on_inventory_item_clicked(index : int, _pos : Vector2, mouse_button_index : int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click. TODO: Make right click bring up interaction menu
		var item = get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		match mode:
			"default": consume_inventory_item(item, index)
			"set_dropper": _set_dropper_item(item)
		
		#print("you dropped " + str(item.qty) + item.display_name + " out of " + stritems[index].qty))
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
	set_item_text(index, generate_item_text(item))
	if item.qty < 1:
		remove_inventory_item(index)
	drag_item.item = da_item
	
	drag_item.texture = item.texture
	drag_item.inventory_ref = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
	get_parent().add_child(drag_item)

func consume_inventory_item(item : Item, index : int):
	update_status_effects.emit(item.on_consume_effects, item.on_consume_message)
	
	if item.qty <= 1:
		remove_inventory_item(index)
	else:
		item.qty -= 1
		set_item_text(index, generate_item_text(item))
	
	# Check item for if it should be removed from the hotbar
	if hotbar_ref.has_item(item):
		var has_more_items := false
		for cur_item in items:
			if cur_item.ID != item.ID:
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
		if cur_item.ID != item.ID:
			continue
		if not is_consumed:
			update_status_effects.emit(cur_item.on_consume_effects, cur_item.on_consume_message)
			is_consumed = true
			if cur_item.qty <= 1:
				remove_inventory_item(i)
				num_items -= 1
			else:
				cur_item.qty -= 1
				set_item_text(i, generate_item_text(cur_item))
				has_more_items = true
		else:
			has_more_items = true
	
	if not has_more_items: # Remove item from hotbar if no more of this item is in inventory
		hotbar_ref.remove_hotbar_item(item)

func _on_hotbar_consume_inventory_item(item: Item) -> void:
	consume_hotbar_item(item)


func _on_tool_wheel_set_dropper_item() -> void:
	_set_mode("set_dropper")

func _set_mode(m: String) -> void:
	if mode == m:
		return
	match m:
		"default": 
			mode = m
		"set_dropper": 
			_open_inventory()
			mode = m

func _set_dropper_item(item: Item):
	toolwheel_ref.dropper_item = item
