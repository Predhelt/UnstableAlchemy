extends Button
## Stores the button's link to a recipe, if any.
var recipe : Recipe

signal ingredient_pressed(r: Recipe)


## When button is pressed, sends a separate signal with the recipe information
## if the button has a stored item recipe.
func _on_pressed() -> void:
	if recipe:
		ingredient_pressed.emit(recipe)
