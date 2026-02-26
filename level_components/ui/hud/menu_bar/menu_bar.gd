extends HBoxContainer

@onready var mode_windows := {
	&"options" : %OptionsMenu,
}

#TODO: Update the keyboard shortcut when the keybinds change or input device changes

func _ready() -> void:
	var cur_action : String = InputMap.action_get_events("inventory")[0].as_text().replace(' (Physical)','')
	$ButtonInventory.set_btn_text(cur_action)
	$ButtonInventory.tooltip_text = ("Inventory (" + cur_action + ")")
	cur_action = InputMap.action_get_events("recipe_book")[0].as_text().replace(' (Physical)','')
	$ButtonRecipes.set_btn_text(cur_action)
	$ButtonRecipes.tooltip_text = ("Recipes (" + cur_action + ")")
	cur_action = InputMap.action_get_events("options_menu")[0].as_text().replace(' (Physical)','')
	$ButtonOptions.set_btn_text(cur_action)
	$ButtonOptions.tooltip_text = ("Options (" + cur_action + ")")
	cur_action = InputMap.action_get_events("log_book")[0].as_text().replace(' (Physical)','')
	$ButtonLogBook.set_btn_text(cur_action)
	$ButtonLogBook.tooltip_text = ("Log Book (" + cur_action + ")")

## Opens the window of the button that was pressed
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
			if cur_window != ui:
				ui.open_window()


func _on_button_inventory_pressed() -> void:
	open_pressed_window(%InventoryMenu)

func _on_button_recipes_pressed() -> void:
	open_pressed_window(%RecipeList)

func _on_button_options_pressed() -> void:
	open_pressed_window(%OptionsMenu)

func _on_button_log_book_pressed() -> void:
	open_pressed_window(%LogBookMenu)
