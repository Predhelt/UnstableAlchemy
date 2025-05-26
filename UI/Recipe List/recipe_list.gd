extends Control

@export var known_recipes : Array[Recipe]

var recipe_item_icon : PackedScene = preload("res://UI/Recipe List/recipe_item_icon.tscn")

func _ready() -> void:
	for recipe in known_recipes:
		%RecipeItems.add_item(recipe.product_item.display_name, recipe.product_item.texture)
	%RecipeItems.visible = true
	
	%WindowName.text = "Known Recipes"
	%ProductDetails.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_open_recipe_book"):
		toggle_window()
	if event.is_action_pressed("ui_cancel"):
		close_window()
	if event.is_action_pressed("ui_toggle_inventory"):
		close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	visible = false
	%ProductDetails.visible = false
	for child in %ProcedureList.get_children(): # Remove all children
		%ProcedureList.remove_child(child)
	%WindowName.text = "Known Recipes"
	%RecipeItems.visible = true
	
	

func open_window() -> void:
	visible = true


func add_recipe(recipe: Recipe):
	var is_in_list := false
	for r in known_recipes:
		if r.id == recipe.id:
			return # Recipe already in known recipes
		if r.product_item.id == recipe.product_item.id:
			is_in_list = true
	
	known_recipes.append(recipe)
	
	if not is_in_list:	
		%RecipeItems.add_item(recipe.product_item.display_name, recipe.product_item.texture)


func _on_recipe_items_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var recipe := known_recipes[index]
	%ProductName.text = recipe.product_item.display_name
	%ProductDescription.text = recipe.product_item.description
	%ProductIcon.texture = recipe.product_item.texture
	
	# Add each procedure to create the associated recipe
	var num_procedures := 0
	for r in known_recipes:
		
		if r.product_item.id != recipe.product_item.id:
			continue
		if num_procedures % 2 == 1:
			var breakline = Label.new()
			breakline.text = "|"
			%ProcedureList.add_child(breakline)
		add_procedure(r)
		num_procedures += 1
	
	%RecipeItems.visible = false
	%WindowName.text = "Item Details"
	%ProductDetails.visible = true
	

func add_procedure(recipe: Recipe):
	var cur_procedures_container = HBoxContainer.new()
	var tool_icon : TextureRect = recipe_item_icon.instantiate()
	match recipe.tool_used:
		"cauldron": 
			tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-cauldron.png")
			tool_icon.tooltip_text = "Ingredients are combined in the Cauldron"
		"m&p":
			tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
			tool_icon.tooltip_text = "Ingredients are added to the Mortar and Pestle"
		"hand": pass
		"blade": pass
		"dropper": pass
	
	cur_procedures_container.add_child(tool_icon)
	
	var label_arrow = Label.new()
	label_arrow.text = "<-"
	cur_procedures_container.add_child(label_arrow)
	
	var num_ingredients := len(recipe.ingredients)
	for item in recipe.ingredients:
		var recipe_icon : TextureRect = recipe_item_icon.instantiate()
		recipe_icon.texture = item.texture
		recipe_icon.tooltip_text = item.display_name
		cur_procedures_container.add_child(recipe_icon)
		
		if num_ingredients > 1:
			var label_add = Label.new()
			label_add.text = "+"
			cur_procedures_container.add_child(label_add)
			num_ingredients -= 1
	
	%ProcedureList.add_child(cur_procedures_container)
	
	
