extends AlchemyTool


func use_items(): # Overrides the use_items() function in AlchemyTool
	# Find first item in queue to start using in the mortar and pestle
	var item : Item
	for i in MAX_ITEMS:
		if items[i]:
			item = items[i]
			remove_item(i)
			break
	
	var result_recipe := failed_craft
	for recipe in recipes:
		if recipe.ingredients[0].ID == item.ID:
			result_recipe = recipe
	
	begin_craft(result_recipe)
