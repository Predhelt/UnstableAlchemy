extends HBoxContainer

#TODO: Add the keyboard shortcut to the tooltip and update it when the keybinds change

func _ready() -> void:
	$ButtonInventory.tooltip_text = ("Inventory (" +
			InputMap.action_get_events("inventory")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonRecipes.tooltip_text = ("Recipes (" +
			InputMap.action_get_events("recipe_book")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonOptions.tooltip_text = ("Options (" +
			InputMap.action_get_events("options_menu")[0].as_text().replace(' (Physical)','') + ")")

func _on_button_inventory_pressed() -> void:
	match global.mode:
		&"default": %Inventory.open_window()
		&"recipe_list": 
			%RecipeList.close_window()
			%Inventory.open_window()
		&"options":
			%OptionsMenu.close_window()
			%Inventory.open_window()


func _on_button_recipes_pressed() -> void:
	match global.mode:
		&"default": %RecipeList.open_window()
		&"inventory": 
			%Inventory.close_window()
			%RecipeList.open_window()
		&"options":
			%OptionsMenu.close_window()
			%RecipeList.open_window()


func _on_button_options_pressed() -> void:
	match global.mode:
		&"default": %OptionsMenu.open_window()
		&"inventory": 
			%Inventory.close_window()
			%OptionsMenu.open_window()
		&"recipe_list": 
			%RecipeList.close_window()
			%OptionsMenu.open_window()
