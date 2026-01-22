## Displays the list of recipes available to the character.
## When a recipe is clicked on, opens a detailed display of the description,
## ingredients, and procedure of the recipe.
extends Panel

#@export var known_recipes : Array[Recipe]
## The currently referenced character.
@onready var character : Character = %Player
## Icons to be preloaded for use in display
var recipe_item_icon : PackedScene = preload("res://UI/Menu/Recipe List/recipe_item_icon.tscn")
var recipe_ingredient_icons : PackedScene = preload("res://UI/Menu/Recipe List/recipe_ingredient_icons.tscn")
var recipe_procedure_icons : PackedScene = preload("res://UI/Menu/Recipe List/recipe_procedure_icons.tscn")
var procedure_icon_grind := preload("res://Art/UAPrototype/UI/Minigame/grind.png")
var procedure_icon_crush := preload("res://Art/UAPrototype/UI/Minigame/crush.png")
var procedure_icon_bellows := preload("res://Art/UAPrototype/UI/Minigame/bellows.png")

func _ready() -> void:
	%WindowName.text = "Known Recipes"
	%ProductDetails.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recipe_book"):
		toggle_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode != &"menu" and global.mode != &"minigame":
		return
	
	visible = false
	global.right_window = null
	if not global.left_window and not global.center_window:
		global.mode = &"default"
	
	for recipe in character.known_recipes:
		%RecipeItems.clear()


func open_window() -> bool:
	if global.right_window or global.center_window:
		return false
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		
		%ProductDetails.visible = false
		for child in %ProcedureList.get_children(): # Remove all children
			%ProcedureList.remove_child(child)
		%WindowName.text = "Known Recipes"
		
		for recipe in character.known_recipes:
			var display_text := ""
			if recipe in character.new_recipes:
				display_text += "*New*"
			display_text += recipe.product_item.display_name
			%RecipeItems.add_item(display_text, recipe.product_item.texture)
		%RecipeItems.visible = true
	
		%ButtonBack.visible = false
		global.right_window = self
		visible = true
		return true
	return false


func _on_recipe_items_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var recipe := character.known_recipes[index]
	%ProductName.text = recipe.product_item.display_name
	%ProductDescription.text = recipe.product_item.description
	%ProductIcon.texture = recipe.product_item.texture
	
	if recipe in character.new_recipes:
		character.new_recipes.erase(recipe)
	
	## Add each procedure to create the associated recipe
	for r in character.known_recipes:
		if r.product_item.id != recipe.product_item.id:
			continue
		if  recipe.tool_used == &"m&p":
			add_ingredients(r)
		add_procedure(r)
	
	%RecipeItems.visible = false
	%WindowName.text = "Item Details"
	%ButtonBack.visible = true
	%ProductDetails.visible = true
	

func add_ingredients(recipe: Recipe):
	var ingredient_display : Control = recipe_ingredient_icons.instantiate()
	var num_ingredients = len(recipe.ingredients)
	
	if num_ingredients > 3:
		print("Error: more than 3 ingredients")
	
	ingredient_display.get_child(1).texture = recipe.ingredients[0].texture
	ingredient_display.get_child(1).tooltip_text = recipe.ingredients[0].display_name
	
	if num_ingredients > 1:
		ingredient_display.get_child(2).text = ","
		ingredient_display.get_child(3).texture = recipe.ingredients[1].texture
		ingredient_display.get_child(3).tooltip_text = recipe.ingredients[1].display_name
	
	if num_ingredients > 2:
		ingredient_display.get_child(4)
		ingredient_display.get_child(5).texture = recipe.ingredients[2].texture
		ingredient_display.get_child(5).tooltip_text = recipe.ingredients[2].display_name
		
	%ProcedureList.add_child(ingredient_display)

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
		&"merger":
			tool_icon.texture = load("res://Art/UAPrototype/Alchemy/Tools/alchemy-abstract_container-half_full.png")
			tool_icon.tooltip_text = "Ingredients are added to the Merger"
		&"hand": pass
		&"blade": pass
		&"dropper": pass
	
	cur_procedures_container.add_child(tool_icon)
	
	var label_arrow = Label.new()
	label_arrow.text = "<-"
	cur_procedures_container.add_child(label_arrow)
	
	if  recipe.tool_used == &"merger":
		var ingredient_icon : TextureRect = recipe_item_icon.instantiate()
		ingredient_icon.texture = recipe.ingredients[0].texture
		ingredient_icon.tooltip_text = recipe.ingredients[0].display_name
		cur_procedures_container.add_child(ingredient_icon)
		
		var label_plus = Label.new()
		label_plus.text = "+"
		cur_procedures_container.add_child(label_plus)
		
		ingredient_icon = recipe_item_icon.instantiate()
		ingredient_icon.texture = recipe.ingredients[1].texture
		ingredient_icon.tooltip_text = recipe.ingredients[1].display_name
		cur_procedures_container.add_child(ingredient_icon)
	
	_add_procedure_input_actions(cur_procedures_container, recipe)
	
	var label_qty = Label.new()
	label_qty.text = "= " + str(recipe.product_item_amount)
	cur_procedures_container.add_child(label_qty)
	var product_icon : TextureRect = recipe_item_icon.instantiate()
	product_icon.texture = recipe.product_item.texture
	product_icon.tooltip_text = recipe.product_item.display_name
	cur_procedures_container.add_child(product_icon)
	
	%ProcedureList.add_child(cur_procedures_container)


func _add_procedure_input_actions(container: HBoxContainer, recipe: Recipe):
	if not recipe.procedure:
		return
	
	var procedure_icons := recipe_procedure_icons.instantiate()
	
	for i in len(recipe.procedure.input_actions): #NOTE: Might cause issues if the length of the procedure is not 5
		## Create new icon for sequence
		var pia_icon := procedure_icons.get_child(0).get_child(i) #Icon of procedure index i
		if not recipe.procedure.input_actions[i]:
			pia_icon.texture = global.blank_texture
			pia_icon.tooltip_text = "No input"
			continue
		if recipe.tool_used == "m&p":
			match recipe.procedure.input_actions[i].id:
				0: 
					pia_icon.texture = procedure_icon_crush
					pia_icon.tooltip_text = "Crush"
				1: 
					pia_icon.texture = procedure_icon_grind
					pia_icon.tooltip_text = "Grind"
		else:
			var cur_ia = recipe.procedure.input_actions[i]
			if cur_ia.type == "equipment":
				match cur_ia.id:
					0:
						pia_icon.texture = procedure_icon_bellows
						pia_icon.tooltip_text = "Bellows"
			elif cur_ia.type == "item":
				for ingredient in recipe.ingredients:
					if cur_ia.id == ingredient.id:
						pia_icon.texture = ingredient.texture
						pia_icon.tooltip_text = ingredient.display_name
		
	container.add_child(procedure_icons)


func _on_button_close_pressed() -> void:
	close_window()


func _on_button_back_pressed() -> void:
	close_window()
	open_window()
