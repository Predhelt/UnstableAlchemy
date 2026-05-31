extends LevelManager

@onready var inventory_menu_ref = $UILayer/MenuLayer/LeftWindows/InventoryMenu

var watched_cutscene: bool = false
var read_grow_book: bool = false
var crafted_green_paste: bool = false
var minigame_opened: bool = false

func _ready() -> void:
	super()
	if watched_cutscene:
		$Cutscene.hide()
	if UserVariables.has_looped:
		return
	if not read_grow_book:
		inventory_menu_ref.set_merger_visibility(false)
	if not crafted_green_paste:
		inventory_menu_ref.set_cauldron_visibility(false)


func save(_dir: String) -> Dictionary:
	var save_dict = {
		"watched_cutscene" : watched_cutscene,
		"read_grow_book" : read_grow_book,
		"crafted_green_paste" : crafted_green_paste,
	}
	return save_dict


func _on_ui_layer_item_used(item: Item) -> void:
	if item.id == 1004: # Grow Potion book
		inventory_menu_ref.set_merger_visibility(true)
		read_grow_book = true


func _on_ui_layer_craft_completed(result: Item, _recipe: Recipe) -> void:
	if result.id == 200: # Green Paste
		inventory_menu_ref.set_cauldron_visibility(true)
		crafted_green_paste = true


func _on_cutscene_end_scene() -> void:
	watched_cutscene = true


func _on_ui_layer_minigame_cauldron_window_opened() -> void:
	minigame_opened = true
	EventHandler.open_popup_message(
		"put the ingredients in the cauldron at the right time.\n
		Match up a procedure from the recipe book."
	)
