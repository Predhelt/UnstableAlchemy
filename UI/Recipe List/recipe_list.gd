extends Node2D

var known_recipes : Array[Recipe]

var recipe_item_icon := preload("res://UI/Recipe List/recipe_item_icon.tscn")

func _ready() -> void:
	%RecipeItems.visible = true
	%ProductDetails.visible = false


func add_recipe(recipe: Recipe):
	for r in known_recipes:
		if r.product_item.ID == recipe.product_item.ID:
			print("New recipe for existing item!")
		else:
			known_recipes.append(recipe)
			%RecipeItems.add_item(recipe.product_item.display_name, recipe.product_item.texture)


func _on_recipe_items_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var recipe := known_recipes[index]
	%ProductName.text = recipe.product_item.display_name
	%ProductDescription.text = recipe.product_item.description
	%ProductIcon.texture = recipe.product_item.texture
	
	# Add each procedure to create the associated recipe
	for r in known_recipes:
		if r.product_item.ID == recipe.product_item.ID:
			add_procedure(r)
	
	%RecipeItems.visible = false
	%ProductDetails.visible = true
	

func add_procedure(recipe: Recipe):
	var container = HBoxContainer.new()
	var tool_icon = recipe_item_icon.instantiate()
	match recipe.tool_used:
		"cauldron": tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-cauldron.png")
		"m&P": tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
		"hand": pass
		"blade": pass
		"dropper": pass
	container.add_child(tool_icon)
	
	var label_arrow = Label.new()
	label_arrow.text = "<-"
	label_arrow.font_size(32)
	container.add_child(label_arrow)
	
	var num_ingredients := len(recipe.ingredients)
	for item in recipe.ingredients:
		var recipe_icon = recipe_item_icon.instantiate()
		recipe_icon.texture = item.texture
		container.add_child(recipe_icon)
		
		if num_ingredients > 1:
			var label_add = Label.new()
			label_add.text = "+"
			label_add.font_size(32)
			container.add_child(label_add)
	
	%ProcedureList.add_child(container)
	
