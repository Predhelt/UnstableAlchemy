extends Control

signal add_inventory_item(item: Item)
signal consume_inventory_item(item: Item)

var hotbar_slots : Array

func _ready() -> void:
	hotbar_slots = $HBoxContainer.get_children()


func _on_add_inventory_item(item: Item) -> void:
	add_inventory_item.emit(item)


func _on_consume_inventory_item(item: Item) -> void:
	consume_inventory_item.emit(item)


func remove_hotbar_item(item: Item) -> void:
	for hb_slot in hotbar_slots:
		if not hb_slot.cur_item:
			continue
		if hb_slot.cur_item.ID == item.ID:
			hb_slot.remove_item()


func has_item(item: Item) -> bool:
	for slot in hotbar_slots:
		if not slot.cur_item:
			continue
		if slot.cur_item.ID == item.ID:
			return true
	return false


func _on_inventory_remove_hotbar_item(item: Item) -> void:
	remove_hotbar_item(item)
