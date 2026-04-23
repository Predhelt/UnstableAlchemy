## UI Scene that represents one item in a shop transaction.
extends TextureRect
## Sets the quantity of the item.
func set_count(c) -> void:
	%ItemCount.text = "x"+str(c)
