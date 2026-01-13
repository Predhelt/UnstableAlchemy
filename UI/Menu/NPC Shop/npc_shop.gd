#This node allows an npc to trade items with the player.
extends Panel

@onready var player : Player = %Player ##Reference to player

var shop_transaction_scene = preload("res://UI/Menu/NPC Shop/shop_transaction.tscn")

@export var transactions : Array[Transaction] ##List of shop transactions available to the player

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
		
		#%ShopTransactions.visible = true
	
		%ButtonBack.visible = false
		visible = true

func add_shop_transactions() -> void:
	for transaction in transactions: #NOTE: Transactions are assigned in parent NPC
		#TODO: convert exported transactions into display items
		#Add items to a transaction, then add each transaction to the shop.
		
		var cur_transaction_scene = shop_transaction_scene.instantiate()
		cur_transaction_scene.connect("attempt_transaction", _on_transaction_attempt) # Connect child signal for when the transaction is pressed to attempt the associated transaction
		cur_transaction_scene.set_transaction(transaction)
		
		if player.inventory_ref.has_inventory_items(transaction.items_buying, transaction.items_buying_amount) == {}:
			cur_transaction_scene.disabled = true
			
		%ShopTransactions.add_child(cur_transaction_scene)

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
	
	#var player_inventory_ref 
	
	
	#for item_buying in cur_transaction.items_buying:
		
		#if item_buying.id in player.inventory_ref and:
			#item_buying.
