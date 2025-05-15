extends Control

signal add_inventory_item(item: Item)


func _on_add_inventory_item(item: Item) -> void:
	add_inventory_item.emit(item)
