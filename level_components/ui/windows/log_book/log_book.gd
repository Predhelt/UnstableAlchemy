## UI Log Book containing various different kinds of information, such as:
## Help pages for details on game mechanics.
## Items pages for details on items the character can pick up or craft.
## Potions pages for details on potions the player can find or craft.
## Plants pages for details on different plants the plaer may encounter.
## Objects pages
## Books pages
## Places pages
## People pages
## Statuses pages

extends UIWindow
var prev_mode : StringName

func _ready() -> void:
	# Set descriptions for pages relating to resources upon scene load
	
	# Plants:
	var scn = load("res://level_components/objects/interactable/plants/blue_berry_bush.tscn").instantiate()
	%PagePlantBlueBerryBush/VBoxContainer/LabelDescription.text = scn.description
	%PagePlantBlueBerryBush/VBoxContainer/LabelContainedItems.text = _interaction_object_contained_items_as_str(scn)
	#FIXME: Object counts should be updated on page load, not level load.
	%PagePlantBlueBerryBush/VBoxContainer/LabelInteractionCounts.text = _interaction_object_counts_as_str(scn.display_name)
	
	#var res : Resource
	# Status Effects:
	#res = load("res://game_systems/status_effects/energized.tres")
	#%ButtonEnergized.icon = res.icon
	#%PageEnergized/VBoxContainer/Label.text = res.description
	#res = load("res://game_systems/status_effects/grow.tres")
	#%ButtonGrow.icon = res.icon
	#%PageGrow/VBoxContainer/Label.text = res.description
	#res = load("res://game_systems/status_effects/self_attunement.tres")
	#%ButtonSelfAttunement.icon = res.icon
	#%PageSelfAttunement/VBoxContainer/Label.text = res.description
	#res = load("res://game_systems/status_effects/shrink.tres")
	#%ButtonShrink.icon = res.icon
	#%PageShrink/VBoxContainer/Label.text = res.description
	#res = load("res://game_systems/status_effects/slow.tres")
	#%ButtonSlow.icon = res.icon
	#%PageSlow/VBoxContainer/Label.text = res.description
	#res = load("res://game_systems/status_effects/strengthen.tres")
	#%ButtonStrengthen.icon = res.icon
	#%PageStrengthen/VBoxContainer/Label.text = res.description

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
	open_page_help_general()
	return true

## Initializes which pages are visible in the log book based on character's stored information.
## If page buttons or sections are visible by default in the node editor, they will remain visible.
## Allows showing of character-specific log entries by passing the character node.
## By default, gets information from global UserVariables.
func init_logs(character : Character = null) -> void:
	var node = character
	if not node:
		node = UserVariables
	for book_id in node.books_read:
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
	for recipe in node.known_recipes:
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
	# Object Pages and context labels based on performed interactions
	for obj_name in node.objects_grab_interacted.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
			%PagePlantRedBerryBush/VBoxContainer/LabelGrab.visible = true
		if obj_name == "Green Herbs":
			%ButtonPlantGreenHerbs.visible = true
			%PagePlantGreenHerbs/VBoxContainer/LabelGrab.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
			%PagePlantYellowFlowers/VBoxContainer/LabelGrab.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true
			%PagePlantBlueBerryBush/VBoxContainer/LabelGrab.visible = true
	for obj_name in node.objects_cut_interacted.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
			%PagePlantRedBerryBush/VBoxContainer/LabelCut.visible = true
		if obj_name == "Green Herb":
			%ButtonPlantGreenHerbs.visible = true
			%PagePlantGreenHerbs/VBoxContainer/LabelCut.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
			%PagePlantYellowFlowers/VBoxContainer/LabelCut.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true
			%PagePlantBlueBerryBush/VBoxContainer/LabelCut.visible = true
	for obj_name in node.objects_combined.keys():
		if obj_name == "Red Berry Bush":
			%ButtonPlantRedBerryBush.visible = true
			%PagePlantRedBerryBush/VBoxContainer/LabelCombine.visible = true
		if obj_name == "Green Herb":
			%ButtonPlantGreenHerbs.visible = true
			%PagePlantGreenHerbs/VBoxContainer/LabelCombine.visible = true
		if obj_name == "Yellow Flowers":
			%ButtonPlantYellowFlowers.visible = true
			%PagePlantYellowFlowers/VBoxContainer/LabelCombine.visible = true
		if obj_name == "Blue Berry Bush":
			%ButtonPlantBlueBerryBush.visible = true
			%PagePlantBlueBerryBush/VBoxContainer/LabelCombine.visible = true

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

########################################
### Open Pages With Dynamic Elements ###
########################################

### Help Tab ###
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

func open_page_help_tools():
	#%WindowName.text = "Help: Tools"
	%PageHelpTools/VBoxContainer/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+"\" to use the currently held tool on a nearby object.")
	
	%PageHelpTools.visible = true


## When close button is pressed, close the log book window.
func _on_button_close_pressed() -> void:
	close_window()

####################################################
### Receive Button Presses, Open Associated Page ###
####################################################

### Help Tab ###
################
func _on_button_help_general_pressed() -> void:
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
	%PagePotionCleanse.visible = true

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
	%PagePlantRedBerryBush.visible = true

func _on_button_plant_green_herbs_pressed() -> void:
	%PagePlantGreenHerbs.visible = true

func _on_button_plant_yellow_flowers_pressed() -> void:
	%PagePlantYellowFlowers.visible = true

func _on_button_plant_blue_berry_bush_pressed() -> void:
	%PagePlantBlueBerryBush.visible = true

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
func _on_button_energized() -> void:
	%PageEnergized.visible = true

func _on_button_grow() -> void:
	%PageGrow.visible = true

func _on_button_self_attunement() -> void:
	%PageSelfAttunement.visible = true

func _on_button_shrink() -> void:
	%PageShrink.visible = true

func _on_button_slow() -> void:
	%PageSlow.visible = true

func _on_button_strengthen() -> void:
	%PageStrengthen.visible = true
