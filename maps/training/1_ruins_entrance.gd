
extends LevelManager


signal call_open_inventory

@onready var inventory_menu_ref = $UILayer/MenuLayer/LeftWindows/InventoryMenu

# Tracks different stages of tutorial messaging
var watched_cutscene: bool = false
var grabbed_flakes_book: bool = false
var grabbed_herb = false
var used_flakes_book: bool = false
var can_use_mp: bool = false
## Closed log book after using recipe book
var closed_log_book: bool = false
var opened_recipe_flakes: bool = false
var mp_minigame_opened: bool = false
var crafted_flakes: bool = false
var used_flakes: bool = false
var plate_pressed: bool = false

## Initialize HUD UI functionality before load potentially overrides this.
func _init() -> void:
	UserVariables.is_inventory_disabled = true
	UserVariables.is_log_book_disabled = true
	UserVariables.is_recipe_book_disabled = true

## Hide UI and disable hotkeys that are not necessary on scene start.
## Uses global and level variables from save data to determine state.
func _ready() -> void:
	super()
	if watched_cutscene:
		$Cutscene.hide()
	if UserVariables.has_looped:
		UserVariables.is_inventory_disabled = false
		UserVariables.is_log_book_disabled = false
		UserVariables.is_recipe_book_disabled = false
		return
	if UserVariables.is_inventory_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonInventory", false)
	if UserVariables.is_log_book_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonLogBook", false)
	if UserVariables.is_recipe_book_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonRecipes", false)
	
	if not can_use_mp:
		inventory_menu_ref.set_mortar_pestle_visibility(false)
	inventory_menu_ref.set_cauldron_visibility(false)
	inventory_menu_ref.set_merger_visibility(false)
	
	for i in range(1, 10):
		$UILayer.set_log_book_tab_hidden(i)
	
	if grabbed_herb:
		$UILayer.set_log_book_tab_hidden(1, false)
	if plate_pressed:
		$UILayer.set_log_book_tab_hidden(5, false)
	if used_flakes_book:
		$UILayer.set_log_book_tab_hidden(2, false)
		$UILayer.set_log_book_tab_hidden(6, false)
	if used_flakes:
		$UILayer.set_log_book_tab_hidden(9, false)
	#$UILayer.set_log_book_button_name_visibility("ButtonHelpInteractions", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpTools", false)
	if not can_use_mp:
		$UILayer.set_log_book_button_name_visibility("ButtonHelpMP", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpCauldron", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpMerger", false)
	$UILayer.set_log_book_button_name_visibility("ButtonObjectBoulder", false)
	$UILayer.set_log_book_button_name_visibility("ButtonObjectWallSmallHole", false)
	
	refresh_input_messages()


func save(_dir: String) -> Dictionary:
	var save_dict = {
		"watched_cutscene" : watched_cutscene,
		"grabbed_flakes_book" : grabbed_flakes_book,
		"grabbed_herb" : grabbed_herb,
		"used_flakes_book" : used_flakes_book,
		"can_use_mp" : can_use_mp,
		"closed_log_book" : closed_log_book,
		"opened_recipe_flakes" : opened_recipe_flakes,
		"mp_minigame_opened" : mp_minigame_opened,
		"crafted_flakes" : crafted_flakes,
		"used_flakes" : used_flakes,
		"plate_pressed" : plate_pressed,
	}
	return save_dict


func refresh_input_messages() -> void:
	$TutorialMessages/LabelMovement.text = (
		"Move with 
		%s %s %s %s
		keys" %
		[InputMap.action_get_events("move_up")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_left")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_down")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_right")[0].as_text().replace(' - Physical','')]
	)
	%LabelInventory.text = (
		"Open your bag with %s.
		
		Right-click items in your bag to use them." %
		InputMap.action_get_events("inventory")[0].as_text().replace(' - Physical','')
	)
	%LabelRecipes.text = (
		"Open the recipe book (%s)." %
			InputMap.action_get_events("recipe_book")[0].as_text().replace(' - Physical','')
	)


func _on_recipe_item_object_grabbed(_body: Character) -> void:
	if not UserVariables.has_looped:
		$UILayer.set_menu_bar_button_name_visibility("ButtonInventory", true)
		UserVariables.is_inventory_disabled = false
		%LabelInventory.visible = true
	grabbed_flakes_book = true


func _on_ui_layer_item_used(item: Item) -> void:
	if item.id == 1000: # Herb Flakes Book
		if not UserVariables.has_looped:
			$UILayer.set_log_book_tab_hidden(6, false)
			$UILayer.set_log_book_tab_hidden(2, false)
			%LabelInventory.visible = false
			$UILayer.set_menu_bar_button_name_visibility("ButtonLogBook", true)
			UserVariables.is_log_book_disabled = false
			EventHandler.open_log_book_page("BookHerbFlakes")
		used_flakes_book = true
	elif not used_flakes and item.id == 100: # Herb Flakes
		if not UserVariables.has_looped:
			$UILayer.set_log_book_tab_hidden(9, false)
			EventHandler.open_log_book_page("StatusEnergizedBurst")
			used_flakes = true


func _on_ui_layer_log_book_menu_window_closed() -> void:
	if used_flakes_book and not closed_log_book:
		if not UserVariables.has_looped:
			$UILayer.set_menu_bar_button_name_visibility("ButtonRecipes", true)
			UserVariables.is_recipe_book_disabled = false
			%LabelRecipes.visible = true
		closed_log_book = true


func _on_cutscene_end_scene() -> void:
	watched_cutscene = true
	if UserVariables.has_looped:
		$Player.update_status_message("What just happened...")
		$TutorialMessages/LabelMovement.visible = false
		return
	$TutorialMessages/LabelMovement.visible = true


func _on_ui_layer_recipe_list_page_opened(item: Item) -> void:
	if not item.id == 100: # Herb Flakes ID
		return
	%LabelRecipes.visible = false
	
	if closed_log_book and not UserVariables.has_looped:
		if not opened_recipe_flakes and not Global.focused_node.inventory.has_item_id(0):
			EventHandler.open_popup_message( #FIXME: This is not a good tutorial.
				"Find the missing ingredient to be able to craft."
			)
			opened_recipe_flakes = true
		elif not can_use_mp and Global.focused_node.inventory.has_item_id(0):
			call_open_inventory.emit()
			inventory_menu_ref.set_mortar_pestle_visibility(true)
			EventHandler.open_popup_message( #FIXME: This is not a good tutorial.
				"Drag items from the inventory onto the tool in the middle.
				Then click the arrow on the tool to begin crafting."
			)
			$UILayer.set_log_book_button_name_visibility("ButtonHelpMP", true)
			can_use_mp = true


func _on_green_herb_object_grabbed(_body: Character) -> void:
	$UILayer.set_log_book_tab_hidden(1, false)
	grabbed_herb = true


func _on_pressure_plate_plate_pressed() -> void:
	if not plate_pressed:
		$UILayer.set_log_book_tab_hidden(5, false)
		EventHandler.open_popup_message(
			"Pressure plates can open doors of the same color.
			Some doors stay open when you step off of the plate.
			Others close slowly, or quickly.
			Some doors require multiple plates to open."
		)
		plate_pressed = true


func _on_ui_layer_craft_completed(result: Item, _recipe: Recipe) -> void:
	if not crafted_flakes and result.id == 100: # Green Flakes
		crafted_flakes = true
		Global.save_game.call_deferred()


func _on_ui_layer_minigame_mp_window_opened() -> void:
	EventHandler.open_popup_message(
			"Use the Mortar & Pestle by moving in the correct sequence.\n
			Crush by pressing up, down, up, down.\n
			Grind by pressing left, right, left, right.\n
			Check the recipe book to see the correct procedures."
		)
	mp_minigame_opened = true
