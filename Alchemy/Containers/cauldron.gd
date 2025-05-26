extends AlchemyTool


func _ready() -> void:
	set_recipes("Cauldron")


func _use_items(): # Overrides the _use_items() function in AlchemyTool
	var brew_ids : Array[int] = []
	for i in MAX_ITEMS:
		if items[i]:
			brew_ids.append(items[i].id)
			remove_item(i)
			
	if brew_ids.is_empty():
		return
	
	brew_ids.sort()
	
	var result_recipe = failed_craft
	
	for recipe in recipes: # Find matching ingredients list in recipes
		var ingredient_ids : Array[int] = []
		for ingredient in recipe.ingredients:
			ingredient_ids.append(ingredient.id)
		ingredient_ids.sort()
		if ingredient_ids == brew_ids:
			result_recipe = recipe
	
	begin_craft(result_recipe)
