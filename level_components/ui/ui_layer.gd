extends CanvasLayer

## Emits when an [Item] is used in the inventory menu. This means consumed.
signal item_used(item: Item)

## Propagate the signal.
func _on_inventory_menu_item_consumed(item: Item) -> void:
	item_used.emit(item)

signal options_menu_window_closed()
signal options_menu_window_opened()
signal log_book_menu_window_closed()
signal log_book_menu_window_opened()
signal inventory_menu_window_closed()
signal inventory_menu_window_opened()
signal recipe_list_window_closed()
signal recipe_list_window_opened()
signal character_shop_window_closed()
signal character_shop_window_opened()
signal character_dialogue_window_closed()
signal character_dialogue_window_opened()
signal minigame_cauldron_window_closed()
signal minigame_cauldron_window_opened()
signal minigame_mp_window_closed()
signal minigame_mp_window_opened()
signal craft_completed(result: Item, recipe: Recipe)
signal call_open_inventory
signal recipe_list_page_opened(item: Item)


func _on_options_menu_window_closed() -> void:
	options_menu_window_closed.emit()


func _on_options_menu_window_opened() -> void:
	options_menu_window_opened.emit()


func _on_log_book_menu_window_closed() -> void:
	log_book_menu_window_closed.emit()


func _on_log_book_menu_window_opened() -> void:
	log_book_menu_window_opened.emit()


func _on_inventory_menu_window_closed() -> void:
	inventory_menu_window_closed.emit()


func _on_inventory_menu_window_opened() -> void:
	inventory_menu_window_opened.emit()


func _on_recipe_list_window_closed() -> void:
	recipe_list_window_closed.emit()


func _on_recipe_list_window_opened() -> void:
	recipe_list_window_opened.emit()


func _on_character_shop_window_closed() -> void:
	character_shop_window_closed.emit()


func _on_character_shop_window_opened() -> void:
	character_shop_window_opened.emit()


func _on_character_dialogue_window_closed() -> void:
	character_dialogue_window_closed.emit()


func _on_character_dialogue_window_opened() -> void:
	character_dialogue_window_opened.emit()


func _on_minigame_cauldron_window_closed() -> void:
	minigame_cauldron_window_closed.emit()


func _on_minigame_cauldron_window_opened() -> void:
	minigame_cauldron_window_opened.emit()


func _on_minigame_mp_window_closed() -> void:
	minigame_mp_window_closed.emit()


func _on_minigame_mp_window_opened() -> void:
	minigame_mp_window_opened.emit()


func _on_inventory_menu_craft_item_added(result: Item, recipe: Recipe) -> void:
	craft_completed.emit(result, recipe)


func _on_world_call_open_inventory() -> void:
	call_open_inventory.emit()

## Changes whether the tab at the given index in the log book is hidden or not.
func set_log_book_tab_hidden(tab_idx: int, is_hidden: bool = true) -> void:
	%LogBookMenu.set_tab_hidden(tab_idx, is_hidden)

## Propagates down the function to se
func set_log_book_button_name_visibility(button_name: String, visibility: bool):
	%LogBookMenu.set_button_name_visibility(button_name, visibility)

func set_menu_bar_button_name_visibility(button_name: String, visibility: bool):
	%MenuBar.set_button_name_visibility(button_name, visibility)


func _on_recipe_list_recipe_page_opened(item: Item) -> void:
	recipe_list_page_opened.emit(item)
