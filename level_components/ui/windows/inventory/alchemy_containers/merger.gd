extends AlchemyTool

##
func _ready() -> void:
	super()
	set_recipes(&"Merger")
	if has_enough_craft_items():
		button_confirm.disabled = false
	else:
		button_confirm.disabled = true

## 
func _use_items(): # Overrides the _use_items() function in AlchemyTool
	var item_ids : Array[int] = []
	for i in MAX_ITEMS:
		if items[i]:
			item_ids.append(items[i].id)
			#remove_item(i)
			
	if item_ids.is_empty():
		return
	
	item_ids.sort()
	
	var result_recipe = FAILED_CRAFT
	
	for recipe in recipes: # Find matching ingredients list in recipes
		var ingredient_ids : Array[int] = []
		for ingredient in recipe.ingredients:
			ingredient_ids.append(ingredient.id)
		ingredient_ids.sort()
		if ingredient_ids == item_ids:
			result_recipe = recipe
	
	if result_recipe == FAILED_CRAFT:
		for item_id in item_ids:
			if item_id == 10: # Mysterious Crystal
				result_recipe = FAILED_CRYSTAL_CRAFT
				break
	
	begin_craft(result_recipe)
	#open_minigame(items)


func has_enough_craft_items() -> bool:
	var count: int = 0
	for i in items:
		if i:
			count += 1
	if count >= 2:
		return true
	return false


func _on_button_1_pressed() -> void:
	super()
	if has_enough_craft_items():
		return
	button_confirm.disabled = true

func _on_button_2_pressed() -> void:
	super()
	if has_enough_craft_items():
		return
	button_confirm.disabled = true

func _on_button_3_pressed() -> void:
	super()
	if has_enough_craft_items():
		return
	button_confirm.disabled = true

func _on_area_item_added(_item: Item) -> void:
	if has_enough_craft_items():
		button_confirm.disabled = false
