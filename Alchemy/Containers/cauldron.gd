extends AlchemyTool


func _ready() -> void:
	set_recipes(&"Cauldron")
	%Minigame.recipes = recipes


func _use_items(): # Overrides the _use_items() function in AlchemyTool
	#var item_ids : Array[int] = []
	#for i in MAX_ITEMS:
		#if items[i]:
			#item_ids.append(items[i].id)
			#remove_item(i)
			#
	#if item_ids.is_empty():
		#return
	#
	#item_ids.sort()
	
	#var result_recipe = failed_craft
	#
	#for recipe in recipes: # Find matching ingredients list in recipes
		#var ingredient_ids : Array[int] = []
		#for ingredient in recipe.ingredients:
			#ingredient_ids.append(ingredient.id)
		#ingredient_ids.sort()
		#if ingredient_ids == item_ids:
			#result_recipe = recipe
	
	open_minigame(items)
