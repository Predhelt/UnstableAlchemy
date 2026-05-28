extends Area2D

signal item_added

func add_item(item: Item):
	get_parent().add_item(item)
	item_added.emit(item)
