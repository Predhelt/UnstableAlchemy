extends Control

@export var known_recipes : Array[Recipe]

var recipe_item_icon : PackedScene = preload("res://UI/Recipe List/recipe_item_icon.tscn")
var procedure_icon_grind := preload("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
var procedure_icon_crush := preload("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
var procedure_icon_bellows := preload("res://Art/UAPrototype/Alchemy/Tools/alchemy-cauldron.png")

func _ready() -> void:
	for recipe in known_recipes:
		%RecipeItems.add_item(recipe.product_item.display_name, recipe.product_item.texture)
	%RecipeItems.visible = true
	
	%WindowName.text = "Known Recipes"
	%ProductDetails.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recipe_book"):
		toggle_window()
	if event.is_action_pressed("ui_cancel"):
		close_window()
	if event.is_action_pressed("inventory"):
		close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode != &"recipe_list":
		return
	
	visible = false
	global.mode = &"default"
	%ProductDetails.visible = false
	for child in %ProcedureList.get_children(): # Remove all children
		%ProcedureList.remove_child(child)
	%WindowName.text = "Known Recipes"
	%RecipeItems.visible = true


func open_window() -> void:
	if global.mode == &"default":
		global.mode = &"recipe_list"
		visible = true


func add_recipe(recipe: Recipe):
	if not recipe:
		return
	
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
		&"cauldron": 
			tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-cauldron.png")
			tool_icon.tooltip_text = "Ingredients are combined in the Cauldron"
		&"m&p":
			tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-mortar_pestle.png")
			tool_icon.tooltip_text = "Ingredients are added to the Mortar and Pestle"
		&"hand": pass
		&"blade": pass
		&"dropper": pass
	
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
	
	_add_procedure_input_actions(cur_procedures_container, recipe)
	#var panel : Panel = Panel.new()
	#panel.
	#panel.add_child(cur_procedures_container)
	%ProcedureList.add_child(cur_procedures_container)


func _add_procedure_input_actions(container: HBoxContainer, recipe: Recipe):
	if not recipe.procedure:
		return
	var lbl : Label = Label.new()
	lbl.text = "Procedure:"
	container.add_child(lbl)
	
	for i in 5: #NOTE: Should be changed if the number of input actions in a sequence is changed
		# Create new icon for sequence
		var pia_icon : TextureRect = recipe_item_icon.instantiate()
		if not recipe.procedure.input_actions[i]:
			pia_icon.texture = global.blank_texture
			pia_icon.tooltip_text = "No input"
			container.add_child(pia_icon)
			continue
		if recipe.tool_used == "m&p":
			match recipe.procedure.input_actions[i].id:
				0: 
					pia_icon.texture = procedure_icon_grind
					pia_icon.tooltip_text = "Grind"
				1: 
					pia_icon.texture = procedure_icon_crush
					pia_icon.tooltip_text = "Crush"
		else:
			match recipe.procedure.input_actions[i].id:
				0: 
					pia_icon.texture = recipe.ingredients[0].texture
					pia_icon.tooltip_text = recipe.ingredients[0].display_name
				1: 
					pia_icon.texture = recipe.ingredients[1].texture
					pia_icon.tooltip_text = recipe.ingredients[1].display_name
				2: 
					pia_icon.texture = recipe.ingredients[2].texture
					pia_icon.tooltip_text = recipe.ingredients[2].display_name
				3: 
					pia_icon.texture = procedure_icon_bellows
					pia_icon.tooltip_text = "Bellows"
		
		
		container.add_child(pia_icon)
