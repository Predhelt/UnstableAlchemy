extends AlchemyTool


func use_items(): # Overrides the use_items() function in AlchemyTool
	var brew_IDs : Array[int]
	for i in MAX_ITEMS:
		if items[i]:
			brew_IDs.append(items[i].ID)
			remove_item(i)
			
	brew_IDs.sort()
	
	var result_recipe = failed_craft
	
	for recipe in recipes: # Find matching ingredients list in recipes
		var ingredient_IDs : Array[int] = []
		for ingredient in recipe.ingredients:
			ingredient_IDs.append(ingredient.ID)
		ingredient_IDs.sort()
		if ingredient_IDs == brew_IDs:
			result_recipe = recipe
	
	begin_craft(result_recipe)
