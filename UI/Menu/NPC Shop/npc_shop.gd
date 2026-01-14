#This node allows an npc to trade items with the player.
extends Panel

@onready var player : Player = %Player ##Reference to player

var shop_transaction_scene := preload("res://UI/Menu/NPC Shop/shop_transaction.tscn")

var transactions : Array[Transaction] ##List of shop transactions available to the player
@export var item_gained_effect := preload("res://Effects/items_gained_effect_ui.tscn")

func _ready() -> void:
	%WindowName.text = "Shop"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode != &"menu" or global.mode == &"minigame":
		return
	
	visible = false
	remove_from_group("menu")
	print(get_tree().get_nodes_in_group("menu"))
	if get_tree().get_nodes_in_group("menu").is_empty():
		global.mode = &"default"
	


func open_window() -> void:
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		
		add_shop_transactions() # Populate the shop transactions
		
		#TODO: Shop opens from Dialogue, enable back button and configure to go back to Dialogue.
		%ButtonBack.visible = false 
		visible = true
		player.inventory_ref.open_window()

func add_shop_transactions() -> void:
	var cur_transaction_id := 0
	for transaction in transactions: #NOTE: Transactions are assigned in interacted NPC
		#Add items UI to a transaction UI, then add each transaction UI to the shop UI.
		transaction.id = cur_transaction_id
		var cur_transaction_scene : Button = shop_transaction_scene.instantiate()
		cur_transaction_scene.name = str(transaction.id)
		cur_transaction_scene.connect("attempt_transaction", _on_transaction_attempt) # Connect child signal for when the transaction is pressed to attempt the associated transaction
		cur_transaction_scene.set_transaction(transaction)
		
		if(player.inventory_ref.has_inventory_items(transaction.items_buying, transaction.items_buying_amount) == {}
				and not transaction.items_buying.is_empty()): # If requesting any items (not giving away items)
			cur_transaction_scene.disabled = true
			
		%ShopTransactions.add_child(cur_transaction_scene)
		cur_transaction_id += 1

func clear_transactions() -> void:
	for t in %ShopTransactions.get_children():
		t.queue_free()

func _on_button_close_pressed() -> void:
	close_window()


func _on_button_back_pressed() -> void:
	close_window()
	open_window()
	
func _on_transaction_attempt(id : int) -> void:
	var cur_transaction : Transaction = null
	for t in transactions:
		if t.id == id:
			cur_transaction = t
			break
	
	if not cur_transaction:
		print("no transaction found with id " + str(id))
		return
	
	# Remove items from inventory
	var cur_items_buying = cur_transaction.items_buying.duplicate() # "remove_inventory_items" changes properties of the transaction. This prevents overwriting transaction quantities.
	var cur_items_buying_amount = cur_transaction.items_buying_amount.duplicate()
	if (cur_items_buying.is_empty() or
		player.inventory_ref.remove_inventory_items(cur_items_buying, cur_items_buying_amount)):
		# Add items to inventory from merchant
		var effect_instance := item_gained_effect.instantiate()
		for i in range(cur_transaction.items_selling.size()):
			var cur_item : Item = cur_transaction.items_selling[i].duplicate()
			cur_item.qty = cur_transaction.items_selling_amount[i] 
			# Pickup effect when items are obtained from shop
			effect_instance.add_item(cur_item) #NOTE: This assumes that the item is successfully added
			player.inventory_ref.add_inventory_item(cur_item)
			
		effect_instance.scale = Vector2(1.3, 1.3)
		self.add_child(effect_instance)
		# Check if player has enough items for another transaction (disable if not enough items)
		if(player.inventory_ref.has_inventory_items(cur_transaction.items_buying, cur_transaction.items_buying_amount) == {}
				and not cur_transaction.items_buying.is_empty()):
			var cur_transaction_scene : Button = %ShopTransactions.get_child(id) # Transaction ID = scene index due to how the window is opened.
			if not cur_transaction_scene:
				print("Error: No scene found for shop with transaction index " + str(id))
				return
			#print("Transaction being disabled with ID " + %ShopTransactions.get_child(id).name)
			cur_transaction_scene.disabled = true
