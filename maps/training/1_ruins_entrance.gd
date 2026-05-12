
extends LevelManager


## Tracks different stages of tutorial messaging

var grabbed_recipe_book: bool = false
var used_recipe_book: bool = false
## Closed log book after using recipe book
var closed_log_book: bool = false
var opened_recipe_menu: bool = false

func _on_recipe_item_object_grabbed(_body: Character) -> void:
	EventHandler.open_popup_message(
		"Open your bag with %s.
		
		Right-click items in your bag to use them." %
		InputMap.action_get_events("inventory")[0].as_text().replace(' - Physical','')
		)
	grabbed_recipe_book = true


func _on_ui_layer_item_used(item: Item) -> void:
	if item.id == 1000:
		used_recipe_book = true


func _on_ui_layer_log_book_menu_window_closed() -> void:
	if grabbed_recipe_book and used_recipe_book and not closed_log_book:
		EventHandler.open_popup_message(
		"Open the recipe book (%s).\n
		Check the log book (%s) to get more info." %
		[InputMap.action_get_events("recipe_book")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("log_book")[0].as_text().replace(' - Physical','')]
		)
		closed_log_book = true


func _on_ui_layer_recipe_list_window_opened() -> void:
	if not opened_recipe_menu and closed_log_book and Global.focused_node.inventory.has_item_id(0):
		EventHandler.open_popup_message(
		"Drag items from the inventory onto the tools in the middle.
		Then click the check mark on the tool to begin crafting."
		)
		opened_recipe_menu = true


func _on_cutscene_cutscene_closed() -> void:
	EventHandler.open_popup_message(
		"Move with WASD keys"
		)
