## Displays the list of recipes available to the character.
## When a recipe is clicked on, opens a detailed display of the description,
## ingredients, and procedure of the recipe.
extends UIWindow

#@export var known_recipes : Array[Recipe]
## The currently referenced character.
@onready var character : Character = %Player
## List of product IDs in the recipe list.
## Prevents the same item appearing multiple times in the recipe list.
var product_ids : Array[int]
## Icon(Node)s to be preloaded for use in display
var recipe_item_icon : PackedScene = preload("./recipe_item_icon.tscn")
var recipe_tool_icon : PackedScene = preload("./recipe_tool_icon.tscn")
var recipe_ingredient_icons : PackedScene = preload("./recipe_ingredient_icons.tscn")
var recipe_procedure_icons : PackedScene = preload("./recipe_procedure_icons.tscn")
var procedure_icon_grind := preload("res://art/pack/ui/minigame/grind.png")
var procedure_icon_crush := preload("res://art/pack/ui/minigame/crush.png")
var procedure_icon_bellows := preload("res://art/pack/ui/minigame/bellows.png")
## Button to be preloaded for initiating a quick craft of the procedure.
var quick_craft_button := preload("./procedure_quick_craft_button.tscn")
## Effect for when quick crafting is successful.
var items_gained_effect : PackedScene = preload("res://art/effects/items_gained_effect_ui.tscn")


func _ready() -> void:
	window_mode = &"menu"
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
	if global.mode != window_mode:
		return
	
	visible = false
	global.right_window = null
	if not global.left_window and not global.center_window:
		global.mode = &"default"
	
	%RecipeItems.clear()
	product_ids.clear()


func open_window() -> bool:
	if global.right_window or global.center_window:
		return false
	if global.mode == &"default" or global.mode == &"menu":
		global.mode = window_mode # Shares mode with inventory, minigame, and help menu
		
		%ProductDetails.visible = false
		for child in %ProcedureList.get_children(): # Remove all children
			%ProcedureList.remove_child(child)
		%WindowName.text = "Known Recipes"
		
		for recipe in character.known_recipes:
			## If a recipe already exists for the item, do not add another recipe item.
			if not recipe or recipe.product_item.id in product_ids:
				continue
			var display_text := ""
			if recipe in character.new_recipes:
				display_text += "*New*"
			display_text += recipe.product_item.display_name
			%RecipeItems.add_item(display_text, recipe.product_item.texture)
			product_ids.append(recipe.product_item.id)
		%RecipeItems.visible = true
	
		%ButtonBack.visible = false
		global.right_window = self
		visible = true
		return true
	return false

## Takes one recipe that produces a certain product item, then finds any other recipes
## that produce the same item. Displays the product item inventory and different procedures
## used to produce the given item.
func open_recipe_page(recipe : Recipe):
	%ProductName.text = recipe.product_item.display_name
	%ProductDescription.text = recipe.product_item.description
	%ProductIcon.texture = recipe.product_item.texture
	
	if recipe in character.new_recipes:
		character.new_recipes.erase(recipe)
	
	## Add each procedure to create the associated product item
	for r in character.known_recipes:
		if r.product_item.id != recipe.product_item.id:
			continue
		if  recipe.tool_used == &"Mortar & Pestle":
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
	var tool_icon : TextureRect = recipe_tool_icon.instantiate()
	match recipe.tool_used:
		&"Cauldron": 
			tool_icon.texture = load("res://art/pack/alchemy/tools/alchemy-cauldron.png")
			tool_icon.tooltip_text = "Ingredients are combined in the Cauldron"
		&"Mortar & Pestle":
			tool_icon.texture = load("res://art/pack/alchemy/tools/alchemy-mortar_pestle.png")
			tool_icon.tooltip_text = "Ingredients are added to the Mortar and Pestle"
		&"Merger":
			tool_icon.texture = load("res://art/pack/alchemy/tools/alchemy-abstract_container-half_full.png")
			tool_icon.tooltip_text = "Ingredients are added to the Merger"
		&"hand": pass
		&"blade": pass
		&"dropper": pass
	
	cur_procedures_container.add_child(tool_icon)
	
	var label_arrow = Label.new()
	label_arrow.text = "<-"
	cur_procedures_container.add_child(label_arrow)
	
	## Set up the merger, if current tool.
	if  recipe.tool_used == &"Merger":
		var ingredient_icon : Button = recipe_item_icon.instantiate()
		ingredient_icon.icon = recipe.ingredients[0].texture
		ingredient_icon.tooltip_text = recipe.ingredients[0].display_name
		_link_ingredient_button_to_recipe(ingredient_icon, recipe.ingredients[0])
		cur_procedures_container.add_child(ingredient_icon)
		
		var label_plus = Label.new()
		label_plus.text = "+"
		cur_procedures_container.add_child(label_plus)
		
		ingredient_icon = recipe_item_icon.instantiate()
		ingredient_icon.icon = recipe.ingredients[1].texture
		ingredient_icon.tooltip_text = recipe.ingredients[1].display_name
		_link_ingredient_button_to_recipe(ingredient_icon, recipe.ingredients[1])
		cur_procedures_container.add_child(ingredient_icon)
	
	## Add the procedure icons.
	_add_procedure_input_actions(cur_procedures_container, recipe)
	
	## Add the product icon and count.
	var label_qty : Label = Label.new()
	label_qty.text = "= " + str(recipe.product_item_amount)
	cur_procedures_container.add_child(label_qty)
	var product_icon : Button = recipe_item_icon.instantiate()
	product_icon.icon = recipe.product_item.texture
	product_icon.tooltip_text = recipe.product_item.display_name
	cur_procedures_container.add_child(product_icon)
	
	%ProcedureList.add_child(cur_procedures_container)
	
	## Add the quick craft button.
	var cur_qcb : Button = quick_craft_button.instantiate()
	cur_qcb.craft_recipe = recipe
	cur_qcb.connect("quick_craft_pressed", _on_quick_craft_pressed)
	
	if _has_craft_items(recipe) and recipe.id in character.crafted_recipes:
		cur_qcb.disabled = false
	else:
		cur_qcb.disabled = true
	
	%ProcedureList.add_child(cur_qcb)

## Helper function that adds each procedure input action button
## and whether the button should be enabled.
func _add_procedure_input_actions(container: HBoxContainer, recipe: Recipe):
	if not recipe.procedure:
		return
	
	var procedure_icons := recipe_procedure_icons.instantiate()
	
	for i in len(recipe.procedure.input_actions): #NOTE: Might cause issues if the length of the procedure is not 5
		## Create new icon for sequence
		var pia_icon : Button = procedure_icons.get_child(0).get_child(i) 
		#Icon of procedure index i
		if not recipe.procedure.input_actions[i]:
			pia_icon.icon = global.blank_texture
			pia_icon.tooltip_text = "No input"
			continue
		if recipe.tool_used == &"Mortar & Pestle":
			match recipe.procedure.input_actions[i].id:
				0: 
					pia_icon.icon = procedure_icon_crush
					pia_icon.tooltip_text = "Crush"
				1: 
					pia_icon.icon = procedure_icon_grind
					pia_icon.tooltip_text = "Grind"
		else:
			var cur_ia = recipe.procedure.input_actions[i]
			if cur_ia.type == "equipment":
				match cur_ia.id:
					0:
						pia_icon.icon = procedure_icon_bellows
						pia_icon.tooltip_text = "Bellows"
			elif cur_ia.type == "item":
				for ingredient in recipe.ingredients:
					if cur_ia.id == ingredient.id:
						pia_icon.icon = ingredient.texture
						pia_icon.tooltip_text = ingredient.display_name
						
						_link_ingredient_button_to_recipe(pia_icon, ingredient)
		
	container.add_child(procedure_icons)

## Determines whether or not the current procedure can be crafted
## with the character's current inventory
func _has_craft_items(recipe : Recipe) -> bool:
	for item in recipe.ingredients:
		var has_item := false
		if not item:
			continue
		if not character.inventory.has_item(item):
			return false
	return true

## Perform the craft, if possible, then add the result to the character's inventory.
## Returns whether or not the craft was successful.
func _on_quick_craft_pressed(recipe : Recipe) -> bool:
	if recipe.id not in character.crafted_recipes:
		print("ERROR: Character has not crafted this recipe before. returning false.")
		return false
	if not _has_craft_items(recipe):
		print("ERROR: character inventory does not have the necessary items to craft. returning false.")
		return false
	for item in recipe.ingredients:
		if not item:
			continue
		if not character.inventory.remove_items([item], [1]):
			print("ERROR: No item " + item.display_name + " found in inventory.")
			return false
	## Add product items to inventory.
	var product_item : Item = recipe.product_item.duplicate()
	product_item.qty = recipe.product_item_amount
	if not character.inventory.add_item(product_item):
		print("ERROR: Product item " + product_item.display_name + 
			" not added successfully to inventory.")
		return false
	## Update the inventory window if it is open while the recipe window is open.
	%InventoryMenu.update_window()
	## Create effect in recipe window to show that the item was added successfuly.
	var effect_instance = items_gained_effect.instantiate()
	effect_instance.add_item(product_item, recipe.product_item.qty)
	effect_instance.scale = Vector2(1.3, 1.3)
	add_child(effect_instance)
	return true

## Uses the button icon reference and ingredient item as input.
## If ingredient is also a known recipe, make it so that when the icon is pressed,
## it links to the ingredient's recipe page.
func _link_ingredient_button_to_recipe(button : Button, item : Item) -> bool:
	## Check to see if the ingredient is a product of a known recipe.
	for r in character.known_recipes:
		if r and item.id == r.product_item.id:
			## Connect the button press action to opening the item's recipe page.
			## This assumes that the recipe item button has a custom 
			## ingredient_pressed signal that emits a recipe.
			button.connect("ingredient_pressed", _on_ingredient_button_pressed)
			button.recipe = r
			return true
	return false

## When an ingredient button in a recipe page is pressed, opens that ingredient's recipe page.
## Inefficient, but closes and reopens the recipe menu for the given ingredient.
func _on_ingredient_button_pressed(recipe : Recipe):
	close_window()
	open_window()
	open_recipe_page(recipe)

## When a recipe item is clicked in the procedure, open that recipe page.
func _on_recipe_items_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	open_recipe_page(character.known_recipes[index])

## Close the window.
func _on_button_close_pressed() -> void:
	close_window()

## Close the current window an reopen the default list of recipes.
func _on_button_back_pressed() -> void:
	close_window()
	open_window()
