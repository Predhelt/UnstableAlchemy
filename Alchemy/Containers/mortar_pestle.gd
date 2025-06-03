extends AlchemyTool


func _ready() -> void:
	set_recipes(&"M&P")
	%MortarPestleMinigame.recipes = recipes

func _use_items(): # Overrides the _use_items() function in AlchemyTool
	#TODO: Make minigame with given ingredients to determine the outcome of the craft
	# Find first item in queue to start using in the mortar and pestle
	var item : Item = null
	for i in MAX_ITEMS:
		if items[i]:
			item = items[i]
			remove_item(i)
			break
	
	if not item:
		return
	
	#var result_recipe := failed_craft
	#for recipe in recipes:
		#if recipe.ingredients[0].id == item.id:
			#result_recipe = recipe
	
	open_minigame(item)
	
