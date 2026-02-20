extends Control
#TODO: Update hotbar so that it works with new system
signal add_inventory_item(item: Item)
signal use_inventory_item(item: Item)

var hotbar_slots : Array

func _ready() -> void:
	hotbar_slots = $Panel/HBoxContainer.get_children()

## Received when an item is removed from a hotbar slot.
## Returns the item to the inventory.
func _on_add_inventory_item(item: Item) -> void:
	add_inventory_item.emit(item)

## Received when an item in a hotbar slot is used.
## Uses the item in the inventory.
func _on_use_inventory_item(item: Item) -> void:
	use_inventory_item.emit(item)


func remove_hotbar_item(item: Item) -> void:
	for hb_slot in hotbar_slots:
		if not hb_slot.cur_item:
			continue
		if hb_slot.cur_item.id == item.id and hb_slot.cur_item.qty == item.qty:
			hb_slot.remove_item()


func has_item(item: Item) -> bool:
	for slot in hotbar_slots:
		if not slot.cur_item:
			continue
		if slot.cur_item.id == item.id:
			return true
	return false


func _on_inventory_remove_hotbar_item(item: Item) -> void:
	remove_hotbar_item(item)
