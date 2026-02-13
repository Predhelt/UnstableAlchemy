extends Button
## Tells the inventory that a quick craft was initiated and sends the craft recipe.
signal quick_craft_pressed(recipe : Recipe)
## Recipe that the quick craft uses to craft the item.
var craft_recipe : Recipe

func _on_pressed() -> void:
	quick_craft_pressed.emit(craft_recipe)
