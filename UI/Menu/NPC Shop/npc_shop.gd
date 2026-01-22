## This node allows an npc to trade items with the player.
extends Panel
## Reference to player that is buying items from the shop.
@onready var player : Player = %Player
## Reference to the inventory menu to be displayed alongside the shop by default.
@onready var inventory_menu := %InventoryMenu
## Scene that sets up the transaction UI for the shop.
var shop_transaction_scene := preload("res://UI/Menu/NPC Shop/shop_transaction.tscn")
## List of shop transactions available to the player.
var transactions : Array[Transaction]
## Visual effect that occurs when an item is gained in the shop from a transaction.
@export var item_gained_effect := preload("res://Effects/items_gained_effect_ui.tscn")
## Keeps track of the previous window for if the back button is pressed.
var last_window_ref : Control

## Initializes the shop window.
func _ready() -> void:
	%WindowName.text = "Shop"

## Handles input action events.
#func _input(event: InputEvent) -> void:
	#TODO: allow input actions to select shop items.

## Toggles the visibility of the window.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Closes the NPC Shop UI window and removes it from the window group.
func close_window() -> void:
	if global.mode != &"menu" or global.mode == &"minigame":
		return
	
	visible = false
	global.right_window = null
	if not global.left_window and not global.center_window:
		global.mode = &"default"
	

## Opens the NPC Shop UI window and adds it to the window group.
func open_window() -> bool:
	if global.right_window or global.center_window:
		return false
	if global.mode == &"default" or global.mode == &"minigame":
		global.mode = &"menu" ## Shares mode with inventory, minigame, and help menu
	if global.mode == &"menu":
		global.right_window = self
		add_shop_transactions() # Populate the shop transactions
		
		#TODO: If shop opens from Dialogue, enable back button and configure to go back to Dialogue.
		inventory_menu.open_window()
		%ButtonBack.visible = false 
		visible = true
		return true
	return false

## Allows back button to be toggled on remotely with reference to the given window.
func show_back_button(window : Control) -> void:
	last_window_ref = window
	%ButtonBack.visible = true

## Adds the stored list of transactions to the shop UI.
func add_shop_transactions() -> void:
	var cur_transaction_id := 0
	for transaction in transactions: #NOTE: Transactions are assigned in interacted NPC
		## Add items UI to a transaction UI, then add each transaction UI to the shop UI.
		transaction.id = cur_transaction_id
		var cur_transaction_scene : Button = shop_transaction_scene.instantiate()
		cur_transaction_scene.name = str(transaction.id)
		cur_transaction_scene.connect("attempt_transaction", _on_transaction_attempt) # Connect child signal for when the transaction is pressed to attempt the associated transaction
		cur_transaction_scene.set_transaction(transaction)
		
		if(player.inventory.has_items(transaction.items_buying, transaction.items_buying_amount) == {}
				and not transaction.items_buying.is_empty()): # If requesting any items (not giving away items)
			cur_transaction_scene.disabled = true
			
		%ShopTransactions.add_child(cur_transaction_scene)
		cur_transaction_id += 1

## Clears the list of transactions from the shop.
func clear_transactions() -> void:
	for t in %ShopTransactions.get_children():
		t.queue_free()

## Triggers when the close button is pressed on the shop window. Closes the shop UI.
func _on_button_close_pressed() -> void:
	close_window()

## Triggers when the back button is pressed on the shop window. Opens the previous window.
## Currently, only the dialogue window can be the previous window so similar structure assumed.
func _on_button_back_pressed() -> void:
	close_window()
	last_window_ref.open_window()

## Triggers when a transaction is pressed at the given id. Removes the requested items from
## the player's inventory and adds the offered items to the player's inventory.
func _on_transaction_attempt(id : int) -> void:
	var cur_transaction : Transaction = null
	for t in transactions:
		if t.id == id:
			cur_transaction = t
			break
	
	if not cur_transaction:
		print("no transaction found with id " + str(id))
		return
	
	## Remove items from inventory
	var cur_items_buying = cur_transaction.items_buying.duplicate() # "remove_items" changes properties of the transaction. This prevents overwriting transaction quantities.
	var cur_items_buying_amount = cur_transaction.items_buying_amount.duplicate()
	if (cur_items_buying.is_empty() or
		player.inventory.remove_items(cur_items_buying, cur_items_buying_amount)):
		## Add items to inventory from merchant
		var effect_instance := item_gained_effect.instantiate()
		for i in range(cur_transaction.items_selling.size()):
			var cur_item : Item = cur_transaction.items_selling[i].duplicate()
			cur_item.qty = cur_transaction.items_selling_amount[i] 
			# Pickup effect when items are obtained from shop
			effect_instance.add_item(cur_item) #NOTE: This assumes that the item is successfully added
			player.inventory.add_item(cur_item)
			
		inventory_menu.update_menu()
		effect_instance.scale = Vector2(1.3, 1.3)
		self.add_child(effect_instance)
		## Check if player has enough items for another transaction (disable if not enough items)
		if(player.inventory.has_items(cur_transaction.items_buying, cur_transaction.items_buying_amount) == {}
				and not cur_transaction.items_buying.is_empty()):
			var cur_transaction_scene : Button = %ShopTransactions.get_child(id) # Transaction ID = scene index due to how the window is opened.
			if not cur_transaction_scene:
				print("Error: No scene found for shop with transaction index " + str(id))
				return
			#print("Transaction being disabled with ID " + %ShopTransactions.get_child(id).name)
			cur_transaction_scene.disabled = true
