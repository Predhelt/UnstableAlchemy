class_name CauldronRecipe extends Resource

@export var ingredient_ids : Array[int]
@export var result_item : Item
@export var result_item_amount := 0
@export var result_craft_time := 0.0

func _init() -> void:
	ingredient_ids.sort()
	
