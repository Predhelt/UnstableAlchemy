extends HBoxContainer

@onready var mode_windows := {
	&"recipe_list" : %RecipeList,
	&"options" : %OptionsMenu,
	&"inventory" : %Inventory,
	#&"help" : %HelpMenu, #TODO: Implement help menu
}

#TODO: Add the keyboard shortcut to the tooltip and update it when the keybinds change

func _ready() -> void:
	$ButtonInventory.tooltip_text = ("Inventory (" +
			InputMap.action_get_events("inventory")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonRecipes.tooltip_text = ("Recipes (" +
			InputMap.action_get_events("recipe_book")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonOptions.tooltip_text = ("Options (" +
			InputMap.action_get_events("options_menu")[0].as_text().replace(' (Physical)','') + ")")

func _on_button_inventory_pressed() -> void:
	if global.mode == &"default":
		%Inventory.open_window()
	else:
		var cur_window = mode_windows[global.mode]
		if cur_window:
			cur_window.close_window()
			%Inventory.open_window()


func _on_button_recipes_pressed() -> void:
	if global.mode == &"default":
		%RecipeList.open_window()
	else:
		var cur_window = mode_windows[global.mode]
		if cur_window:
			cur_window.close_window()
			%RecipeList.open_window()


func _on_button_options_pressed() -> void:
	if global.mode == &"default":
		%OptionsMenu.open_window()
	else:
		var cur_window = mode_windows[global.mode]
		if cur_window:
			cur_window.close_window()
			%OptionsMenu.open_window()


func _on_button_help_pressed() -> void:
	if global.mode == &"default":
		%HelpMenu.open_window()
	else:
		var cur_window = mode_windows[global.mode]
		if cur_window:
			cur_window.close_window()
			%HelpMenu.open_window()
