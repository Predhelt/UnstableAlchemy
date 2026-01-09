extends Panel

@onready var player : Player = %Player

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
	
	%ShopTransactions.queue_free()


func open_window() -> void:
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		
		add_shop_transactions() # Populate the shop transactions
		
		%ShopTransactions.visible = true
	
		%ButtonBack.visible = false
		visible = true

func add_shop_transactions() -> void:
	for transaction in transactions: #NOTE: Transactions are assigned by parent NPC
		#TODO: convert exported transactions into display items
		#Add items to a transaction, then add each transaction to the shop.
		
		var cur_transaction_scene = shop_transaction_scene.instantiate()
		for itembi in range(transaction.items_buying_amount):
			cur_transaction_scene.add_shop_item(transaction.items_buying[itembi], true)
		for itemsi in range(transaction.items_selling_amount):
			cur_transaction_scene.add_shop_item(transaction.items_selling[itemsi], false)
			
		%ShopTransactions.add_child(cur_transaction_scene)

func _on_button_close_pressed() -> void:
	close_window()


func _on_button_back_pressed() -> void:
	close_window()
	open_window()
