extends Control

signal add_inventory_item(item: Item)

@export var slot_id : int
var player_ref : Player

var cur_item : Item


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_slot_" + str(slot_id)):
		print("hotbar " + str(slot_id))


func add_item(item: Item) -> bool:
	cur_item = item
	add_inventory_item.emit(item) # The hotbar is representing the item so the item goes back into the inventory
	$TextureRect.texture = item.texture
	return true
