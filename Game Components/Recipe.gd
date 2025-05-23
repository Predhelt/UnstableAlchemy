class_name Recipe extends Resource

@export var product_item : Item
@export var ingredients : Array[Item]
@export var tool_used := ""

@export var product_item_amount := 0
@export var product_craft_time := 0.0

#func _init() -> void:
	# Order the ingredients from least ID to greatest for consistency
	#var ordered_ingredients : Array[Item]
	#
	#for i in len(ingredients):
		#var min_ingredient : Item = null
		#var min_index := 0
		#for j in len(ingredients):
			#if not min_ingredient or ingredients[j].ID < min_ingredient.ID:
				#min_ingredient = ingredients[j]
				#min_index = j
		#ordered_ingredients.append(min_ingredient)
		#ingredients.remove_at(min_index)
	#
	#ingredients = ordered_ingredients
