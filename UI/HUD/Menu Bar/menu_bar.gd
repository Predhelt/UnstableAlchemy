extends HBoxContainer

@onready var mode_windows := {
	&"options" : %OptionsMenu,
}

#TODO: Update the keyboard shortcut when the keybinds change or input device changes

func _ready() -> void:
	$ButtonInventory.tooltip_text = ("Inventory (" +
			InputMap.action_get_events("inventory")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonRecipes.tooltip_text = ("Recipes (" +
			InputMap.action_get_events("recipe_book")[0].as_text().replace(' (Physical)','') + ")")
	$ButtonOptions.tooltip_text = ("Options (" +
			InputMap.action_get_events("options_menu")[0].as_text().replace(' (Physical)','') + ")")


func open_pressed_window(ui : Control):
	if global.mode == &"default":
		ui.open_window()
	else:
		if global.mode == &"menu":
			ui.toggle_window()
		elif global.mode in mode_windows:
			var cur_window = mode_windows[global.mode]
			if cur_window:
				cur_window.close_window()
				ui.open_window()


func _on_button_inventory_pressed() -> void:
	open_pressed_window(%Inventory)

func _on_button_recipes_pressed() -> void:
	open_pressed_window(%RecipeList)

func _on_button_options_pressed() -> void:
	open_pressed_window(%OptionsMenu)

func _on_button_help_pressed() -> void:
	open_pressed_window(%HelpMenu)
