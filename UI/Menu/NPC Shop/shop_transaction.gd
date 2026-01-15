extends Button

var transaction_id : int = -1 ## Transaction ID that is stored as reference for the parent npc_shop list of transactions.

var shop_item_scene = preload("res://UI/Menu/NPC Shop/shop_item.tscn")

signal attempt_transaction(id : int)

func set_transaction(transaction : Transaction): ## Sets the information of the transaction to be displayed by the scene
	if transaction_id >=0:
		print("transaction already set")
		return
	
	transaction_id = transaction.id
	
	if transaction.items_buying_amount.size() == 0:
		var no_item_scene : Label = Label.new()
		no_item_scene.text = "None"
		%BuyingContainer.add_child(no_item_scene)
	else:
		for itembi in range(transaction.items_buying_amount.size()): ## index of item the merchant is buying in the transaction
			var new_item_scene : TextureRect = shop_item_scene.instantiate() #NOTE: Assumes that the item scene is of type TextureRect. This needs to be changed if the shop_item scene type changes.
			new_item_scene.texture = transaction.items_buying[itembi].texture
			new_item_scene.set_count(transaction.items_buying_amount[itembi])
			new_item_scene.tooltip_text = transaction.items_buying[itembi].display_name
			%BuyingContainer.add_child(new_item_scene)
	
	for itemsi in range(transaction.items_selling_amount.size()): ## index of item the merchant is selling in the transaction
		var new_item_scene : TextureRect = shop_item_scene.instantiate() #NOTE: Assumes that the item scene is of type TextureRect. This needs to be changed if the shop_item scene type changes.
		new_item_scene.texture = transaction.items_selling[itemsi].texture
		new_item_scene.set_count(transaction.items_selling_amount[itemsi])
		new_item_scene.tooltip_text = transaction.items_selling[itemsi].display_name
		%SellingContainer.add_child(new_item_scene)

func _on_pressed() -> void:
	attempt_transaction.emit(transaction_id)
