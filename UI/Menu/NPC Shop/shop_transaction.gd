extends Button

var shop_item_scene = preload("res://UI/Menu/NPC Shop/shop_item.tscn")

func add_transaction_item(item : Item, isBuying : bool):
	var new_item_scene : TextureRect = shop_item_scene.instantiate() #NOTE: Assumes that the item scene is of type TextureRect. This needs to be changed if the shop_item scene type changes.
	new_item_scene.texture = item.texture
	new_item_scene.set_count(item.qty)
	new_item_scene.tooltip_text = item.display_name
	
	if isBuying:
		%BuyingContainer.add_child(new_item_scene)
	else: # If not buying the item, is selling the item
		%SellingContainer.add_child(new_item_scene)


func _on_pressed() -> void:
	pass # Replace with function body.
