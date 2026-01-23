extends UIWindow

# DEPRECATED: Sent to the player to update their status effects when an item in inventory is consumed
signal update_status_effects(on_consume_effects : Array[StatusEffect], on_consume_message : String)

## Max number of slots in the inventory
@export var max_item_count := 24 
## Reference to the currently used inventory. Sets the default referenced character as Player.
@onready var character_ref : Character = %Player
## visual for item when dragging from inventory
var drag_item_scene := preload("res://UI/Menu/Inventory Menu/drag_item_scene.tscn") 
## Reference to the Hotbar UI
@onready var hotbar_ref := %Hotbar
## Reference to the Tool Wheel UI
@onready var toolwheel_ref := %ToolWheel
## (UNUSED)Item that is currently selected in the inventory (not dragged)
#var selected_item : Item 

## Sets references, initializes variables in references, and connects signals
func _ready() -> void:
	window_mode = &"menu"
	%ItemList.item_clicked.connect(on_inventory_item_clicked)
	%Cauldron.minigame_ref = %MinigameCauldron
	%Cauldron.minigame_ref.recipes = %Cauldron.recipes
	%MinigameCauldron.tool_ref = %Cauldron
	%MortarPestle.minigame_ref = %MinigameMP
	%MortarPestle.minigame_ref.recipes = %MortarPestle.recipes
	%MinigameMP.tool_ref = %MortarPestle
	
	## Signal connections for minigame windows.
	## The naming convention is assumed to be the same across maps.
	%MinigameCauldron.item_produced.connect(_on_item_produced)
	%MinigameMP.item_produced.connect(_on_item_produced)
	%MinigameCauldron.item_removed.connect(_on_item_removed)
	%MinigameMP.item_removed.connect(_on_item_removed)

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
	if global.mode == window_mode:
		global.left_window = null
		if not global.right_window and not global.center_window:
			global.mode = &"default"
		visible = false
	
	elif global.mode == &"dropper":
		global.left_window = null
		global.mode = &"default" ## There should be no other UI windows open
		visible = false
	
	elif global.mode == &"minigame": ## Minigame in progress, do not change groups.
		visible = false
	
	return_alchemy_items()

## Goes through each slot in the alchemy tools in the inventory and
## returns the items back to the inventory.
func return_alchemy_items() -> void:
	for i in range(3):
		character_ref.inventory.add_item(%Cauldron.items[i])
		%Cauldron.remove_item(i)
		character_ref.inventory.add_item(%MortarPestle.items[i])
		%MortarPestle.remove_item(i)
		character_ref.inventory.add_item(%Merger.items[i])
		%Merger.remove_item(i)

## Opens the window and adds it to the active window group.
## Inventory reference should be set before the window is opened.
func open_window() -> bool:
	if global.left_window or global.center_window or visible:
		return false ## Do not open, there is already a window open in the area.
	if not character_ref:
		print("ERROR: No character reference to display inventory")
		return false ## Cannot configure inventory menu without an inventory reference.
	if global.mode == &"default":
		global.mode = window_mode
	if global.mode == window_mode:
		update_window()
		global.left_window = self
		%WindowName.text = "Inventory and Crafting"
		visible = true
		return true
	elif global.mode == &"dropper":
		update_window()
		global.left_window = self
		%WindowName.text = "Select an Item for the Dropper"
		visible = true
		return true
	return false

## Clear the inventory item list, then re-initialize the item list with the items
## in the currently referenced character's inventory.
func update_window():
	%ItemList.clear()
	var items := character_ref.inventory.items
	
	for i in items.size():
		if items[i] == null:
			continue
		if items[i]:
			%ItemList.add_item(generate_item_text(items[i]), items[i].texture)

## Adds an item to the character's inventory, then updates the menu.
func add_inventory_item(item : Item) -> bool:
	if not item or not character_ref.inventory.add_item(item):
		return false
	update_window()
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
	
	character_ref.inventory.items.remove_at(index)
	%ItemList.remove_item(index)

### Removes the list of inventory items from the inventory.
### If isRemoveingStacks is true, removes any stack that contains any item in the array of items.
func remove_inventory_items(items_removing : Array[Item], qtys : Array[int], isRemovingStacks : bool = false) -> bool: ## Returns false if not enough items are found for each item in the inventory
	if not character_ref.inventory.remove_items(items_removing, qtys, isRemovingStacks):
		return false
	update_window()
	return true

## Determines what to do when the item is clicked on.
func on_inventory_item_clicked(index : int, _pos : Vector2, mouse_button_index : int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT: # Right click.
		var item = character_ref.inventory.get_inventory_item(index)
		
		if item == null:
			print("No items found")
			return
		
		match global.mode:
			&"menu": use_item(item, index)
			&"dropper": pass
		
		#print("you dropped " + str(item.qty) + item.display_name + " out of " + stritems[index].qty))
	if mouse_button_index == MOUSE_BUTTON_LEFT: # Left mouse pressed
		var item = character_ref.inventory.get_inventory_item(index)
		
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
	drag_item_instance.inventory_menu = self # Keep reference of inventory for drag item for if dropped outside of a draggable area
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
		for cur_item in character_ref.inventory.items:
			if cur_item.id != item.id:
				continue
			has_more_items = true
			break
		
		if not has_more_items:
			hotbar_ref.remove_hotbar_item(item)

## Adds item from the hotbar to the inventory.
func _on_hotbar_add_inventory_item(item: Item) -> void:
	character_ref.inventory.add_item(item)

## Uses the item on the hotbar and removes it from the inventory.
func consume_hotbar_item(item : Item):
	var has_more_items := false
	var is_consumed := false
	var num_items := len(character_ref.inventory.items)
	
	for i in num_items:
		if num_items <= i: # If item is removed from inventory, will prevent accessing invalid index of inventory
			break
		var cur_item = character_ref.inventory.items[i]
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

## Triggers when a crafting minigame is completed and an item is added to the inventory.
func _on_item_produced(item: Item, recipe: Recipe = null) -> void:
	if item:
		add_inventory_item(item)
	if recipe != null:
		%Player.learn_recipe(recipe)

func _on_item_removed(item: Item) -> void:
	if item:
		remove_inventory_items([item], [1])

## Triggers when the inventory window is opened.
## Adds the inventory to the window group and updates the window title.
func _on_open_inventory() -> void:
	open_window()

## Triggers to close the inventory window.
## Removes the inventory from the window group and hides the window.
func _on_close_inventory() -> void:
	close_window()

## Triggers when the button used to close the window is pressed, which closes the window.
func _on_button_close_pressed() -> void:
	close_window()
