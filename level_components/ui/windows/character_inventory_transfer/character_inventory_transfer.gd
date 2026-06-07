extends UIWindow

var character_ref: Character = null


func _ready() -> void:
	window_mode = &"transfer"


func open_window() -> bool:
	if Global.right_window or Global.center_window:
		return false
	if Global.mode == &"default" or Global.mode == &"menu":
		Global.mode = window_mode
		%WindowName.text = "Transfer %s's Items" % character_ref.character_name
		
		update_inventory()
	
		%ButtonBack.visible = false
		Global.right_window = self
		#$AudioStreamPlayer["parameters/switch_to_clip"] = &"open"
		#$AudioStreamPlayer.play()
		visible = true
		window_opened.emit()
		return true
	return false


func close_window():
	if Global.mode != window_mode:
		return
	visible = false
	window_closed.emit()
	Global.right_window = null
	if not Global.left_window and not Global.center_window:
		Global.mode = &"default"
	if Global.left_window and not Global.center_window:
		Global.mode = &"menu"
		Global.left_window.setup_window("Inventory and Crafting")
	
	character_ref = null


func update_inventory() -> void:
	%ItemListCharacter.clear()
	var items : Array[Item] = character_ref.inventory.items
	
	for i in items.size():
		if items[i] == null:
			continue
		if items[i]:
			%ItemListCharacter.add_item(generate_item_text(items[i]), items[i].texture)

## Sets the text of the item as displayed in the Inventory UI.
func generate_item_text(item: Item) -> String:
	var text := ""
	if item.max_qty > 1:
		text += str(item.qty) + " | "
	text += item.display_name + " | " + item.description
	return text


## Transfers [param item] to the focused node's inventory
func transfer_item(item : Item, index : int) -> void:
	var single_item : Item = item.duplicate()
	single_item.qty = 1
	Global.focused_node.add_traded_item(single_item)
	
	if item.qty <= 1 and item.qty != -1:
		remove_inventory_slot(index)
	elif item.qty != -1:
		item.qty -= 1
		%ItemListCharacter.set_item_text(index, generate_item_text(item))

## Removes the slot/stack of the inventory item at the given index in the inventory.
func remove_inventory_slot(index : int) -> void:
	if index < 0 or index >= %ItemListCharacter.item_count:
		return
	
	character_ref.inventory.items.remove_at(index)
	%ItemListCharacter.remove_item(index)

## Determines what to do when the item is clicked on.
func _on_item_list_character_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click.
		var item = character_ref.inventory.get_inventory_item(index)
		
		if item == null:
			print("WARNING: No items found")
			return
		
		transfer_item(item, index)
		%InventoryMenu.update_window()


func _on_button_close_pressed() -> void:
	close_window()
