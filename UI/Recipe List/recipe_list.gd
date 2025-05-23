extends Control

@export var known_recipes : Array[Recipe]

var recipe_item_icon := preload("res://UI/Recipe List/recipe_item_icon.tscn")

func _ready() -> void:
	for recipe in known_recipes:
		%RecipeItems.add_item(recipe.product_item.display_name, recipe.product_item.texture)
	%RecipeItems.visible = true
	
	%WindowName.text = "Known Recipes"
	%ProductDetails.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_open_recipe_book"):
		_toggle_window()
	if event.is_action_pressed("ui_cancel"):
		_close_window()

func _toggle_window() -> void:
	if visible:
		_close_window()
	else:
		_open_window()

func _close_window() -> void:
	visible = false
	%ProductDetails.visible = false
	for child in %ProcedureList.get_children(): # Remove all children
		%ProcedureList.remove_child(child)
	%WindowName.text = "Known Recipes"
	%RecipeItems.visible = true
	
	

func _open_window() -> void:
	visible = true


func add_recipe(recipe: Recipe):
	var is_in_list := false
	for r in known_recipes:
		if r.id == recipe.id:
			return # Recipe already in known recipes
		if r.product_item.ID == recipe.product_item.ID:
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
	for r in known_recipes:
		if r.product_item.ID == recipe.product_item.ID:
			add_procedure(r)
	
	%RecipeItems.visible = false
	%WindowName.text = "Item Details"
	%ProductDetails.visible = true
	

func add_procedure(recipe: Recipe):
	var cur_procedures_panel = Panel.new()
	var cur_procedures_container = HBoxContainer.new()
	var tool_icon = recipe_item_icon.instantiate()
	match recipe.tool_used:
		"cauldron": tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-cauldron.png")
		"m&p": tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
		"hand": pass
		"blade": pass
		"dropper": pass
	cur_procedures_container.add_child(tool_icon)
	
	var label_arrow = Label.new()
	label_arrow.text = "<-"
	cur_procedures_container.add_child(label_arrow)
	
	var num_ingredients := len(recipe.ingredients)
	for item in recipe.ingredients:
		var recipe_icon = recipe_item_icon.instantiate()
		recipe_icon.texture = item.texture
		cur_procedures_container.add_child(recipe_icon)
		
		if num_ingredients > 1:
			var label_add = Label.new()
			label_add.text = "+"
			cur_procedures_container.add_child(label_add)
			num_ingredients -= 1
	
	cur_procedures_panel.add_child(cur_procedures_container)
	%ProcedureList.add_child(cur_procedures_panel)
	
