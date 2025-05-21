extends Control

signal add_inventory_item(item: Item)
signal consume_inventory_item(item: Item)

@export var slot_id : int

var cur_item : Item


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_slot_" + str(slot_id)):
		if cur_item:
			consume_inventory_item.emit(cur_item)


func add_item(item: Item) -> bool:
	cur_item = item
	add_inventory_item.emit(cur_item) # The hotbar is representing the item so the item goes back into the inventory
	$TextureRect.texture = item.texture
	return true


func remove_item():
	cur_item = null
	$TextureRect.texture = global.blank_texture
