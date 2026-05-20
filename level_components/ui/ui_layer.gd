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


func _on_minigame_cauldron_craft_completed(result: Item, recipe: Recipe) -> void:
	craft_completed.emit(result, recipe)


func _on_minigame_mp_craft_completed(result: Item, recipe: Recipe) -> void:
	craft_completed.emit(result, recipe)
