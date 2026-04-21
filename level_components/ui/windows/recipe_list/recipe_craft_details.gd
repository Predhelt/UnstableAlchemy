extends Control
## Tells the inventory that a quick craft was initiated and sends the craft recipe.
signal quick_craft_pressed(recipe : Recipe)
## Recipe that the quick craft uses to craft the item.
var craft_recipe : Recipe


func _on_button_quick_craft_pressed() -> void:
	quick_craft_pressed.emit(craft_recipe)

func set_craft_count(count : int) -> void:
	$HBoxContainer/LabelCraftCount.text = str(count)

func set_quick_craft_enabled(is_enabled : bool = true):
	$ButtonQuickCraft.disabled = not is_enabled

func set_quick_craft_tooltip(txt : String):
	$ButtonQuickCraft.tooltip_text = txt
