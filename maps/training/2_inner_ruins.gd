extends LevelManager

signal call_open_inventory

@onready var inventory_menu_ref = $UILayer/MenuLayer/LeftWindows/InventoryMenu

var watched_cutscene: bool = false
var read_grow_book: bool = false
var crafted_green_paste: bool = false
var seen_cauldron_hint1: bool = false
var minigame_opened: bool = false

func _ready() -> void:
	super()
	if watched_cutscene:
		$Cutscene.hide()
	if UserVariables.has_looped:
		return
	$UILayer.set_log_book_tab_hidden(8, true)
	if not UserVariables.knows_recipe_id(503): # Grow Potion
			inventory_menu_ref.set_merger_visibility(false)
			$UILayer.set_log_book_tab_hidden(3, true)
	if not UserVariables.has_crafted_recipe_id(100): # Green Paste
		inventory_menu_ref.set_cauldron_visibility(false)


func save(_dir: String) -> Dictionary:
	var save_dict = {
		"watched_cutscene" : watched_cutscene,
		"read_grow_book" : read_grow_book,
		"crafted_green_paste" : crafted_green_paste,
		"seen_cauldron_hint1" : seen_cauldron_hint1,
		"minigame_opened" : minigame_opened,
	}
	return save_dict


func _on_ui_layer_item_used(item: Item) -> void:
	if item.id == 1004: # Grow Potion book
		inventory_menu_ref.set_merger_visibility(true)
		$UILayer.set_log_book_tab_hidden(3, false)
		EventHandler.open_log_book_page("PotionGrow")
		read_grow_book = true


func _on_ui_layer_craft_completed(result: Item, _recipe: Recipe) -> void:
	if result.id == 200: # Green Paste
		inventory_menu_ref.set_cauldron_visibility(true)
		crafted_green_paste = true


func _on_cutscene_end_scene() -> void:
	watched_cutscene = true


func _on_ui_layer_minigame_cauldron_window_opened() -> void:
	if UserVariables.has_looped:
		minigame_opened = true
	if minigame_opened:
		return
	minigame_opened = true
	EventHandler.open_popup_message(
		"Put the ingredients in the cauldron at the right time.\n
		Aim for better accuracy for better results!"
	)


func _on_ui_layer_recipe_list_page_opened(item: Item) -> void:
	if UserVariables.has_looped:
		seen_cauldron_hint1 = true
	if seen_cauldron_hint1:
		return
	if item.id == 503: # Grow Potion
		seen_cauldron_hint1 = true
		call_open_inventory.emit()
		EventHandler.open_popup_message("Drag items in inventory that match the procedure onto the cauldron in the middle.")
