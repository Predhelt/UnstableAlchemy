## UI Log Book containing various different kinds of information, such as:
## Help pages for details on game mechanics.
## Items pages for details on items the character can pick up or craft.
## Potions pages for details on potions the player can find or craft.
## Plants pages for details on different plants the plaer may encounter.
## Objects pages for details on interactable objects that are not plants.
## Books pages for the contents of books that the player has access to.
## Places pages for information on locations that the player knows about.
## People pages for informaion on people that the user has met.
## Statuses pages for information on status effects that the player can encounter.
extends UIWindow

## Tracks the mode prior to the log book opening.
var prev_mode : StringName
## Reference to the current character/node whose information is being used to display the log book.
var character_ref : Node = UserVariables

## Tracks the current item being referenced in the items tab.
var current_item : Item
## Tracks the current potion being referenced in the potions tab.
var current_potion : Potion
## Tracks the current plant's scene being referenced in the plants tab.
var current_plant_scene : Node2D

func _ready() -> void:
	# Default pages on each tab
	%ButtonHelpGeneral.button_pressed = true
	%ButtonHelpGeneral.pressed.emit()
	%ButtonItemGreenHerb.button_pressed = true
	%ButtonItemGreenHerb.pressed.emit()
	%ButtonPotionCleanse.button_pressed = true
	%ButtonPotionCleanse.pressed.emit()
	%ButtonPlantGreenHerbs.button_pressed = true
	%ButtonPlantGreenHerbs.pressed.emit()
	%ButtonObjectBoulder.button_pressed = true
	%ButtonObjectBoulder.pressed.emit()
	%ButtonBookRawMaterials.button_pressed = true
	%ButtonBookRawMaterials.pressed.emit()
	%ButtonPlacesBotania.button_pressed = true
	%ButtonPlacesBotania.pressed.emit()
	%ButtonPeoplePerson1.button_pressed = true
	%ButtonPeoplePerson1.pressed.emit()
	%ButtonStatusEnergized.button_pressed = true
	%ButtonStatusEnergized.pressed.emit()
	
	$VBoxContainer/TabContainer.current_tab = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("log_book"):
		toggle_window()

## Changes the window from opened to closed and vice versa.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Hides the window after removing it from the appropriate group.
func close_window() -> void:
	if Global.mode == window_mode:
		Global.mode = prev_mode
		Global.center_window = null
		prev_mode = ""
		visible = false

## Opens the log book to the default "Help: General" page.
func open_window() -> bool:
	if Global.center_window or visible:
		print("Log Book could not be open, " + Global.center_window.name + " window already open")
		return false ## Do not open, there is already a window open in the area.
	
	prev_mode = Global.mode
	Global.mode = window_mode
	Global.center_window = self
	
	init_logs()
	
	#%WindowName.text = "Help: General"
	#$VBoxContainer/TabContainer/TabHelp.visible = true
	visible = true
	#FIXME: Menus in background can prevent tab buttons from being pressed
	# open the current page in the current tab
	open_page_in_tab($VBoxContainer/TabContainer.current_tab)
	return true

## Initializes which pages are visible in the log book based on character's stored information.
## If page buttons or sections are visible by default in the node editor, they will remain visible.
## Allows showing of character-specific log entries by passing the character node.
## By default, gets information from global UserVariables.
func init_logs(character : Character = null) -> void:
	character_ref = character
	if not character_ref:
		character_ref = UserVariables
	for book_id in character_ref.books_read:
		match book_id:
			1000: ## Green Flakes Book
				pass
			1001: ## Strength Potion Book
				pass
			1002: ## Red Berry Seed Book
				pass
			1003: ## Shrink Potion Book
				%ButtonBookShrinkPotion.visible = true
			1004: ## 
				pass
			1005:
				pass
	for recipe in character_ref.known_recipes:
		match recipe.id:
			### M&P ###
			0: ## Green Herb Flakes
				pass
			1: ## Gray Juice
				pass
			2: ## Red Berry Seed
				pass
			3: ## Yellow Dust
				pass
			4: ## Stem Strands
				pass
			5: ## Red Juice
				pass
			6: ## Blue Berry Seed
				pass
			### Merger ###
			100: ## Green Paste
				pass
			101: ## Yellow Paste
				pass
			102: ## Orange Paste
				pass
			103: ## Saturated Stem
				pass
			### Cauldron ###
			500: ## Speed Potion
				pass
			501: ## Cleanse Potion
				pass
			502: ## Normalize Potion
				pass
			503: ## Grow Potion
				pass
			504: ## Shrink Potion
				pass
			505: ## Speed Potion (2)
				pass
			506: ## Strength Potion
				pass
			### Misc ###
			999: ## Failed Craft
				pass
	# Button visibility for Object Pages based on performed interactions
	for obj_name in character_ref.objects_grab_interacted.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
		if obj_name == "Green Herbs":
			%ButtonPlantGreenHerbs.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true
	for obj_name in character_ref.objects_cut_interacted.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
		if obj_name == "Green Herb":
			%ButtonPlantGreenHerbs.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true
	for obj_name in character_ref.objects_combined.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
		if obj_name == "Green Herb":
			%ButtonPlantGreenHerbs.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true

## Returns the node of the page that is currently open in the given tab index.
## If index is -1, gets the currently open tab's open page node.
func get_current_page(tab_index : int =  -1) -> MarginContainer:
	if tab_index == -1:
		tab_index = $VBoxContainer/TabContainer.current_tab
	var inner_tab : TabContainer = $VBoxContainer/TabContainer.get_child(tab_index).get_child(0).get_child(1)
	inner_tab.get_child(inner_tab.current_tab)
	#print(inner_tab.get_child(inner_tab.current_tab).name)
	return inner_tab.get_child(inner_tab.current_tab)

## Uses the given interaction object to display the amounts of each item contained in the object.
func _interaction_object_contained_items_as_str(obj : InteractableObject) -> String:
	var ostr : String = "Contains: "
	if not obj.items:
		return "Does not contain items."
	var i : int = 0
	for item in obj.items:
		ostr += "%s %s" % [item.qty, item.display_name]
		if i < obj.items.size()-1:
			ostr += ", "
		i += 1
	return ostr

## Uses the given object name to create a string with the counts of different interactions performed.
func _interaction_object_counts_as_str(object_name : String) -> String:
	var ostr : String = ""
	if object_name in UserVariables.objects_grab_interacted.keys():
		ostr += "Times Grabbed: %s, " % str(UserVariables.objects_grab_interacted[object_name][1])
	else:
		ostr += "Times Grabbed: 0, "
	
	if object_name in UserVariables.objects_cut_interacted.keys():
		ostr += "Times Cut: %s, " % str(UserVariables.objects_cur_interacted[object_name][1])
	else:
		ostr += "Times Cut: 0, "
	
	if object_name in UserVariables.objects_combined.keys():
		ostr += "Times Combined: %s" % str(UserVariables.objects_combined[object_name][1])
	else:
		ostr += "Times Combined: 0"
	return ostr

##################
### Open Pages ###
##################

## 
func open_page_help_general():
	#%WindowName.text = "Help: General"
	%PageHelpGeneral/VBoxContainer/LabelToolUse.text = ("Walk near a plant or object "+
	"and use a tool on it by pressing \"" +
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+ "\".")
	%PageHelpGeneral/VBoxContainer/LabelInteraction.text = ("You can talk to other characters by pressing \"" +
		InputMap.action_get_events("interact")[0].as_text().replace(' - Physical','')
		+ "\".")
	
	%PageHelpGeneral.visible = true

## 
func open_page_help_interactions():
	#%WindowName.text = "Help: Interactions"
	%PageHelpInteractions/VBoxContainer/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+"\" to use the currently held tool on a nearby object.")
	if not InputMap.action_get_events("inspect_object").is_empty():
		%PageHelpInteractions/VBoxContainer/LabelInspect.text = ("Press \""+
			InputMap.action_get_events("inspect_object")[0].as_text().replace(' - Physical','')
			+"\" to inspect a nearby object and get a description of it.")
	else:
		%PageHelpInteractions/VBoxContainer/LabelInspect.text = "(Inspection not currently possible)"
	
	%PageHelpInteractions.visible = true

##
func open_page_help_tools():
	#%WindowName.text = "Help: Tools"
	%PageHelpTools/VBoxContainer/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+"\" to use the currently held tool on a nearby object.")
	
	%PageHelpTools.visible = true

##
func open_help_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_item_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_potion_page(page : MarginContainer) -> void:
	page.visible = true

## Opens the provided page that exists under the plant tab.
## Assumes only one Combine label.
func open_plant_page(page : MarginContainer) -> void:
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_plant_scene.display_name)
		return
	if not current_plant_scene:
		print("ERROR: No scene currently referenced for plant page.")
		return
	
	page.get_child(0).find_child("LabelDescription").text = current_plant_scene.description
	page.get_child(0).find_child("LabelContainedItems").text = _interaction_object_contained_items_as_str(current_plant_scene)
	page.get_child(0).find_child("LabelInteractionCounts").text = _interaction_object_counts_as_str(current_plant_scene.display_name)
	
	if current_plant_scene.display_name in character_ref.objects_grab_interacted.keys():
		page.get_child(0).find_child("LabelGrab").visible = true
	if current_plant_scene.display_name in character_ref.objects_cut_interacted.keys():
		page.get_child(0).find_child("LabelCut").visible = true
	if current_plant_scene.display_name in character_ref.objects_combined.keys():
		page.get_child(0).find_child("LabelCombine").visible = true
	
	page.visible = true

##
func open_object_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_book_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_place_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_person_page(page : MarginContainer) -> void:
	page.visible = true

##
func open_status_page(page : MarginContainer) -> void:
	page.visible = true

## Loads the currently open page in the given tab.
func open_page_in_tab(tab: int) -> void:
	match tab:
		0: open_help_page(get_current_page(tab))
		1: open_item_page(get_current_page(tab))
		2: open_potion_page(get_current_page(tab))
		3: open_plant_page(get_current_page(tab))
		4: open_object_page(get_current_page(tab))
		5: open_book_page(get_current_page(tab))
		6: open_place_page(get_current_page(tab))
		7: open_person_page(get_current_page(tab))
		8: open_status_page(get_current_page(tab))

#####################
### Other Signals ###
#####################

## TODO:When the tab is changed, update the currently visible page on the new tab.
func _on_tab_container_tab_changed(tab: int) -> void:
	if not is_node_ready():
		return
	open_page_in_tab(tab)

## When close button is pressed, close the log book window.
func _on_button_close_pressed() -> void:
	close_window()

####################################################
### Receive Button Presses, Open Associated Page ###
####################################################

### Help Tab ###
################
func _on_button_help_general_pressed() -> void:
	#current_help_page = %PageHelpGeneral
	open_page_help_general()

func _on_button_help_interactions_pressed() -> void:
	open_page_help_interactions()

func _on_button_help_tools_pressed() -> void:
	open_page_help_tools()

func _on_button_help_mortar_pestle_pressed() -> void:
	#%WindowName.text = "Help: Mortar & Pestle"
	%PageHelpMP.visible = true

func _on_button_help_cauldron_pressed() -> void:
	#%WindowName.text = "Help: Cauldron"
	%PageHelpCauldron.visible = true

func _on_button_help_merger_pressed() -> void:
	#%WindowName.text = "Help: Merger"
	%PageHelpMerger.visible = true

### Item Tab ###
################
func _on_button_item_blue_berries_pressed() -> void:
	#%WindowName.text = "Item: Blue Berries"
	%PageItemBlueBerries.visible = true

func _on_button_item_blue_juice_pressed() -> void:
	#%WindowName.text = "Item: Blue Juice"
	%PageItemBlueJuice.visible = true

func _on_button_item_blue_seed_pressed() -> void:
	#%WindowName.text = "Item: Blue Seed"
	%PageItemBlueBerrySeed.visible = true

func _on_button_item_flower_stem_pressed() -> void:
	#%WindowName.text = "Item: Flower Stem"
	%PageItemFlowerStem.visible = true

func _on_button_item_gray_juice_pressed() -> void:
	#%WindowName.text = "Item: Gray Juice"
	%PageItemGrayJuice.visible = true

func _on_button_item_gray_seed_pressed() -> void:
	#%WindowName.text = "Item: Gray Seed"
	%PageItemGraySeed.visible = true

func _on_button_item_green_flakes_pressed() -> void:
	#%WindowName.text = "Item: Green Flakes"
	%PageItemGreenFlakes.visible = true

func _on_button_item_green_herb_pressed() -> void:
	#%WindowName.text = "Item: Green Herb"
	%PageItemGreenHerb.visible = true

func _on_button_item_green_paste_pressed() -> void:
	#%WindowName.text = "Item: Green Paste"
	%PageItemGreenPaste.visible = true

func _on_button_item_orange_paste_pressed() -> void:
	#%WindowName.text = "Item: Orange Paste"
	%PageItemOrangePaste.visible = true

func _on_button_item_red_berries_pressed() -> void:
	#%WindowName.text = "Item: Red Berries"
	%PageItemRedBerries.visible = true

func _on_button_item_red_juice_pressed() -> void:
	#%WindowName.text = "Item: Red Juice"
	%PageItemRedJuice.visible = true

func _on_button_item_red_seed_pressed() -> void:
	#%WindowName.text = "Item: Red Seed"
	%PageItemRedBerrySeed.visible = true

func _on_button_item_saturated_stem_pressed() -> void:
	#%WindowName.text = "Item: Saturated Stem"
	%PageItemSaturatedStem.visible = true

func _on_button_item_stem_strands_pressed() -> void:
	#%WindowName.text = "Item: Stem Strands"
	%PageItemStemStrands.visible = true

func _on_button_item_yellow_dust_pressed() -> void:
	#%WindowName.text = "Item: Yellow Dust"
	%PageItemYellowDust.visible = true

func _on_button_item_yellow_paste_pressed() -> void:
	#%WindowName.text = "Item: Yellow Paste"
	%PageItemYellowPaste.visible = true

func _on_button_item_yellow_petals_pressed() -> void:
	#%WindowName.text = "Item: Yellow Petals"
	%PageItemYellowPetals.visible = true

### Potion Tab ###
##################
func _on_button_potion_cleanse_pressed() -> void:
	open_potion_page(%PagePotionCleanse)



func _on_button_potion_grow_pressed() -> void:
	%PagePotionGrow.visible = true

func _on_button_potion_normalize_pressed() -> void:
	%PagePotionNormalize.visible = true

func _on_button_potion_shrink_pressed() -> void:
	%PagePotionShrink.visible = true

func _on_button_potion_slow_pressed() -> void:
	%PagePotionSlow.visible = true

func _on_button_potion_speed_pressed() -> void:
	%PagePotionSpeed.visible = true

func _on_button_potion_strength_pressed() -> void:
	%PagePotionStrengthen.visible = true

### Plant Tab ###
#################
func _on_button_plant_red_berry_bush_pressed() -> void:
	current_plant_scene =  load("res://level_components/objects/interactable/plants/red_berry_bush.tscn").instantiate()
	open_plant_page(%PagePlantRedBerryBush)
	

func _on_button_plant_green_herbs_pressed() -> void:
	current_plant_scene = load("res://level_components/objects/interactable/plants/green_herb.tscn").instantiate()
	open_plant_page(%PagePlantGreenHerbs)


func _on_button_plant_yellow_flowers_pressed() -> void:
	current_plant_scene = load("res://level_components/objects/interactable/plants/yellow_flowers.tscn").instantiate()
	open_plant_page(%PagePlantYellowFlowers)

func _on_button_plant_blue_berry_bush_pressed() -> void:
	current_plant_scene = load("res://level_components/objects/interactable/plants/blue_berry_bush.tscn").instantiate()
	open_plant_page(%PagePlantBlueBerryBush)

### Object Tab ###
##################
func _on_button_object_boulder_pressed() -> void:
	%PageObjectBoulder.visible = true

func _on_button_object_sliding_door_pressed() -> void:
	%PageObjectSlidingDoor.visible = true

func _on_button_object_crawlspace_pressed() -> void:
	%PageObjectCrawlSpace.visible = true

func _on_button_object_pressure_plate_pressed() -> void:
	%PageObjectPressurePlate.visible = true

### Book Tab ###
################
func _on_button_book_raw_materials_pressed() -> void:
	%PageBookRawMaterials.visible = true

func _on_button_book_letter_from_r_pressed() -> void:
	%PageBookLetterFromR.visible = true

func _on_button_book_shrink_potion_pressed() -> void:
	%PageBookShrinkPotion.visible = true

### Places Tab ###
##################
func _on_button_places_botania_pressed() -> void:
	%PagePlacesBotania.visible = true

### People Tab ###
##################
func _on_button_people_person_1_pressed() -> void: #Placeholder
	%PagePeoplePerson1.visible = true

### Status Effects Tab ###
##########################
func _on_button_status_energized_pressed() -> void:
	%PageEnergized.visible = true

func _on_button_status_grow_pressed() -> void:
	%PageGrow.visible = true

func _on_button_status_self_attunement_pressed() -> void:
	%PageSelfAttunement.visible = true

func _on_button_status_shrink_pressed() -> void:
	%PageShrink.visible = true

func _on_button_status_slow_pressed() -> void:
	%PageSlow.visible = true

func _on_button_status_strengthen_pressed() -> void:
	%PageStrengthen.visible = true
