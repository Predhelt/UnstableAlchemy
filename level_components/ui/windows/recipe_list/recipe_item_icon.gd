extends Button
## Stores the button's link to a recipe, if any.
var item : Item

signal ingredient_pressed(i : Item)


## When button is pressed, sends a separate signal with the recipe information
## if the button has a stored item recipe.
func _on_pressed() -> void:
	if item:
		ingredient_pressed.emit(item)
