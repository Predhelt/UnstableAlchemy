
extends LevelManager


signal call_open_inventory

# Tracks different stages of tutorial messaging
var grabbed_recipe_book: bool = false
var used_recipe_book: bool = false
## Closed log book after using recipe book
var closed_log_book: bool = false
var opened_recipe_menu: bool = false

## Initialize HUD UI functionality before load potentially overrides this.
func _init() -> void:
	Global.is_inventory_disabled = true
	Global.is_log_book_disabled = true
	Global.is_recipe_book_disabled = true

## Hide UI and disable hotkeys that are not necessary on scene start.
func _ready() -> void:
	super()
	if UserVariables.has_looped:
		return
	if Global.is_inventory_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonInventory", false)
	if Global.is_log_book_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonLogBook", false)
	if Global.is_recipe_book_disabled:
		$UILayer.set_menu_bar_button_name_visibility("ButtonRecipes", false)
	
	for i in range(1, 11):
		$UILayer.set_log_book_tab_hidden(i)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpInteractions", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpTools", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpMP", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpCauldron", false)
	$UILayer.set_log_book_button_name_visibility("ButtonHelpMerger", false)
	
	$TutorialMessages/LabelMovement.text = (
		"Move with 
		%s %s %s %s
		keys" %
		[InputMap.action_get_events("move_up")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_left")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_down")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("move_right")[0].as_text().replace(' - Physical','')]
	)


func _on_recipe_item_object_grabbed(_body: Character) -> void:
	if not UserVariables.has_looped:
		$UILayer.set_menu_bar_button_name_visibility("ButtonInventory", true)
		Global.is_inventory_disabled = false
		%LabelInventory.text = (
			"Open your bag with %s.
			
			Right-click items in your bag to use them." %
			InputMap.action_get_events("inventory")[0].as_text().replace(' - Physical','')
			)
		%LabelInventory.visible = true
	grabbed_recipe_book = true


func _on_ui_layer_item_used(item: Item) -> void:
	if item.id == 1000:
		$UILayer.set_log_book_tab_hidden(6, false)
		%LabelInventory.visible = false
		used_recipe_book = true


func _on_ui_layer_log_book_menu_window_closed() -> void:
	if grabbed_recipe_book and used_recipe_book and not closed_log_book:
		if not UserVariables.has_looped:
			$UILayer.set_menu_bar_button_name_visibility("ButtonRecipes", true)
			Global.is_recipe_book_disabled = false
			$UILayer.set_menu_bar_button_name_visibility("ButtonLogBook", true)
			Global.is_log_book_disabled = false
			%LabelRecipes.text = (
				"Open the recipe book (%s).\n
				Check the log book (%s) to get more info." %
				[InputMap.action_get_events("recipe_book")[0].as_text().replace(' - Physical',''),
				InputMap.action_get_events("log_book")[0].as_text().replace(' - Physical','')]
				)
			%LabelRecipes.visible = true
		closed_log_book = true


func _on_cutscene_end_scene() -> void:
	if UserVariables.has_looped:
		$Player.update_status_message("What just happened...")
		$TutorialMessages/LabelMovement.visible = false
		return
	$TutorialMessages/LabelMovement.visible = true


func _on_tree_exiting() -> void:
	Global.is_inventory_disabled = false
	Global.is_log_book_disabled = false
	Global.is_recipe_book_disabled = false


func _on_ui_layer_recipe_list_page_opened(item: Item) -> void:
	if not item.id == 100: # Herb Flakes ID
		return
	%LabelRecipes.visible = false
	if not opened_recipe_menu and closed_log_book and Global.focused_node.inventory.has_item_id(0):
		if not UserVariables.has_looped:
			call_open_inventory.emit()
			EventHandler.open_popup_message( #FIXME: This is not a good tutorial.
				"Drag items from the inventory onto the tools in the middle.
				Then click the check mark on the tool to begin crafting."
				)
		opened_recipe_menu = true
