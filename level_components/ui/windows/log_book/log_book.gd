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

## Theme used for buttons whose pages are new.
var new_button_theme : Theme = preload("res://art/styles/red_button_theme.tres")

#TODO: Add tab for cutscenes that have been viewed?
## Tracks the mode prior to the log book opening.
var prev_mode : StringName
## Reference to the current character/node whose information is being used to display the log book.
var character_ref := UserVariables

# trackers for tabs with dynamic page elements.
## Tracks the current item being referenced in the raw items tab.
var current_raw_item : Item
## Tracks the current item being referenced in the crafted items tab.
var current_crafted_item : Item
## Tracks the current potion being referenced in the potions tab.
var current_potion : Potion
## Tracks the current plant's scene being referenced in the plants tab.
var current_plant_scene : Node2D
## Tracks the current object's scene being referenced in the objects tab.
var current_object_scene : Node2D
## Tracks the current book being referenced in the books tab.
#var current_book : Book
## Tracks the current status effect being referenced in the statuses tab.
var current_status_effect : StatusEffect
## Tracks the current cutscene image being referenced in the cutscenes tab.
var current_cutscene : Texture2D

func _ready() -> void:
	# Default pages on each tab
	%ButtonHelpGeneral.button_pressed = true
	%ButtonHelpGeneral.pressed.emit()
	%ButtonItemGreenHerbLeaf.button_pressed = true
	%ButtonItemGreenHerbLeaf.pressed.emit()
	%ButtonPotionCleanse.button_pressed = true
	%ButtonPotionCleanse.pressed.emit()
	%ButtonPlantGreenHerbs.button_pressed = true
	%ButtonPlantGreenHerbs.pressed.emit()
	%ButtonItemGreenFlakes.button_pressed = true
	%ButtonItemGreenFlakes.pressed.emit()
	%ButtonObjectBoulder.button_pressed = true
	%ButtonObjectBoulder.pressed.emit()
	%ButtonBookRawMaterials.button_pressed = true
	%ButtonBookRawMaterials.pressed.emit()
	%ButtonPlacesBotania.button_pressed = true
	%ButtonPlacesBotania.pressed.emit()
	%ButtonPeoplePerson1.button_pressed = true
	%ButtonPeoplePerson1.pressed.emit()
	%ButtonStatusCleanse.button_pressed = true
	%ButtonStatusCleanse.pressed.emit()
	%ButtonCutsceneMap1.button_pressed = true
	%ButtonCutsceneMap1.pressed.emit()
	$AudioStreamPlayer.stop()
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
	if Global.mode != window_mode:
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "close"
	Global.mode = prev_mode
	Global.center_window = null
	prev_mode = ""
	visible = false
	window_closed.emit()

## Opens the log book to the default "Help: General" page.
func open_window() -> bool:
	if  Global.is_log_book_disabled:
		return false
	if Global.center_window or Global.left_window or Global.right_window or visible:
		#print("ERROR: Log Book could not be open, " + Global.center_window.name + " window already open")
		return false ## Do not open, there is already a window open in the area.
	
	prev_mode = Global.mode
	Global.mode = window_mode
	Global.center_window = self
	
	set_buttons_visibility()
	
	# Open the current page in the current tab
	open_page_in_tab($VBoxContainer/TabContainer.current_tab)
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "open"
	visible = true
	window_opened.emit()
	return true

## Initializes which pages are visible in the log book based on character's stored information.
## Allows character-specific log entries to be shown by passing the character node.
## By default, gets information from global UserVariables.
func set_buttons_visibility(character : Node = null) -> void:
	# Reset button visibility
	hide_dynamic_buttons()
	
	character_ref = character
	if not character_ref:
		character_ref = UserVariables
	for item_id in character_ref.gathered_items.keys():
		match item_id:
			0: # Green Herb Leaf
				show_button(%ButtonItemGreenHerbLeaf)
			1: # Red Berries
				show_button(%ButtonItemRedBerries)
			2: # Yellow Petals
				show_button(%ButtonItemYellowPetals)
			3: # Flower Stem
				show_button(%ButtonItemFlowerStem)
			4: # Blue Berries
				show_button(%ButtonItemBlueBerries)
			10: # Mysterious Crystal
				show_button(%ButtonItemCrystal)
	for book_id in character_ref.books_read:
		match book_id:
			1000: # Green Flakes Book
				show_button(%ButtonBookHerbFlakes)
			1001: # Strength Potion Book
				pass
			1002: # Red Berry Seed Book
				pass
			1003: # Shrink Potion Book
				show_button(%ButtonBookShrinkPotion)
			1004: # Grow Potion Book
				pass
				#show_button(%ButtonBookGrowPotion)
			1007: # Possession Potion Book
				show_button(%ButtonBookPossessionPotion)
			2000: # Letter from R
				show_button(%ButtonBookLetterFromR)
			2001: # Crystal Hint 1
				show_button(%ButtonBookCrystalHint1)
			2002: # Crystal Hint 2
				show_button(%ButtonBookCrystalHint2)
			2003: # Crystal Hint 3
				show_button(%ButtonBookCrystalHint3)
			2004: # Crystal Hint 4
				show_button(%ButtonBookCrystalHint4)
			2005: # Crystal Hint 5
				show_button(%ButtonBookCrystalHint5)
	for recipe in character_ref.known_recipes:
		match recipe.id:
			### M&P ###
			0: # Green Herb Flakes
				show_button(%ButtonItemGreenFlakes)
			1: # Gray Juice
				show_button(%ButtonItemGrayJuice)
			2: # Red Berry Seed
				show_button(%ButtonItemRedSeed)
			3: # Yellow Dust
				show_button(%ButtonItemYellowDust)
			4: # Stem Strands
				show_button(%ButtonItemStemStrands)
			5: # Red Juice
				show_button(%ButtonItemRedJuice)
			6: # Blue Berry Seed
				show_button(%ButtonItemBlueSeed)
			### Merger ###
			100: # Green Paste
				show_button(%ButtonItemGreenPaste)
			101: # Yellow Paste
				show_button(%ButtonItemYellowPaste)
			102: # Orange Paste
				show_button(%ButtonItemOrangePaste)
			103: # Saturated Stem
				show_button(%ButtonItemSaturatedStem)
			### Cauldron ###
			500: # Speed Potion
				show_button(%ButtonPotionSpeed)
			501: # Cleanse Potion
				show_button(%ButtonPotionCleanse)
			502: # Normalize Potion
				show_button(%ButtonPotionNormalize)
			503: # Grow Potion
				show_button(%ButtonPotionGrow)
			504: # Shrink Potion
				show_button(%ButtonPotionShrink)
			505: # Speed Potion (2)
				pass
			506: # Strength Potion
				show_button(%ButtonPotionStrength)
			508: # Possession Potion
				show_button(%ButtonPotionPossession)
			509: # Possession Potion (Weak)
				show_button(%ButtonPotionPossessionWeak)
			510: # Self-Attunement
				show_button(%ButtonPotionSelfAttunement)
			### Misc ###
			999: # Failed Craft
				pass
	# Check shop transactions for alternate way of acquiring items.
	for trade_item_id in character_ref.items_trade_received.keys():
		match trade_item_id:
			502: # Normalize Potion
				show_button(%ButtonPotionNormalize)
			509: # Weak Possession Potion
				show_button(%ButtonPotionPossessionWeak)
	# Check used items
	for used_item_id in character_ref.items_used.keys():
		match used_item_id:
			502: # Normalize Potion
				show_button(%ButtonPotionNormalize)
			509: # Weak Possession Potion
				show_button(%ButtonPotionPossessionWeak)
	# Button visibility for Object Pages based on performed interactions
	for obj_name in character_ref.objects_grab_interacted.keys():
		match obj_name:
			"Red Berry Bush":
				show_button(%ButtonPlantRedBerryBush)
			"Green Herbs":
				show_button(%ButtonPlantGreenHerbs)
			"Yellow Flowers":
				show_button(%ButtonPlantYellowFlowers)
			"Blue Berry Bush":
				show_button(%ButtonPlantBlueBerryBush)
	for obj_name in character_ref.objects_cut_interacted.keys():
		match obj_name:
			"Red Berry Bush":
				show_button(%ButtonPlantRedBerryBush)
			"Green Herb":
				show_button(%ButtonPlantGreenHerbs)
			"Yellow Flowers":
				show_button(%ButtonPlantYellowFlowers)
			"Blue Berry Bush":
				show_button(%ButtonPlantBlueBerryBush)
	for obj_name in character_ref.objects_combined.keys():
		match obj_name:
			"Red Berry Bush":
				show_button(%ButtonPlantRedBerryBush)
			"Green Herb":
				show_button(%ButtonPlantGreenHerbs)
			"Yellow Flowers":
				show_button(%ButtonPlantYellowFlowers)
			"Blue Berry Bush":
				show_button(%ButtonPlantBlueBerryBush)
	# Button visibility for Status Effects
	for se_id in character_ref.learned_status_effects:
		match se_id:
			0: # Energized & Burst NOTE: Same page for burst and energized due to sorting by ID.
				show_button(%ButtonStatusEnergized)
			1: # Slow
				show_button(%ButtonStatusSlow)
			2: # Shrink
				show_button(%ButtonStatusShrink)
			3: # Grow
				show_button(%ButtonStatusGrow)
			4: # Strengthen
				show_button(%ButtonStatusStrengthen)
			5: # Self-Attunement
				show_button(%ButtonStatusSelfAttunement)
			100: # Cleanse
				show_button(%ButtonStatusCleanse)
			101: # Normalize
				show_button(%ButtonStatusNormalize)
			200: # Possess
				show_button(%ButtonStatusPossess)
			201: # Possess (Weak)
				show_button(%ButtonStatusPossessWeak)
	# Button visibility for Cutscenes based on ID
	for scene_id in UserVariables.cutscenes_watched:
		match scene_id:
			0: # Map 1
				show_button(%ButtonCutsceneMap1)
			1: # Approaching Ruins
				show_button(%ButtonCutsceneApproachingRuins)
			2: # Map 2
				show_button(%ButtonCutsceneMap2)
			3: # Enter Ruins
				show_button(%ButtonCutsceneEnterRuins)
			4: # Map 3
				show_button(%ButtonCutsceneMap3)
			5: # Cave Entrance 1
				show_button(%ButtonCutsceneCaveEntrance1)
			6: # Cave Entrance 2
				show_button(%ButtonCutsceneCaveEntrance2)
			7: # Discovery
				show_button(%ButtonCutsceneDiscovery)
			8: # Go Home
				show_button(%ButtonCutsceneGoHome)
			9: # Failed Crystal Craft
				show_button(%ButtonCutsceneFailedCrystalCraft)
			10: # Consumed Crystal
				show_button(%ButtonCutsceneConsumedCrystal)
			11: # Rewind 1
				show_button(%ButtonCutsceneRewind1)
			12: # Rewind 2
				show_button(%ButtonCutsceneRewind2)
			13: # Crystal Stabilized
				show_button(%ButtonCutsceneCrystalStabilized)

## Hides all buttons whose visibility is changed dynamically based on the character/user's data.
func hide_dynamic_buttons() -> void:
	# Hide Raw Item Buttons
	for button in %TabRawItems/HBoxContainer/PageButtons/MarginContainer/PageButtonList.get_children():
		if button == %ButtonItemGreenHerbLeaf:
			continue
		button.visible = false
	# Hide most Crafted Item Buttons
	for button in %TabCraftedItems/HBoxContainer/PageButtons/MarginContainer/PageButtonList.get_children():
		if button == %ButtonItemGreenFlakes:
			continue
		button.visible = false
	# Hide most Potion Buttons
	for button in %TabPotions/HBoxContainer/PageButtons/PageButtonList.get_children():
		if button == %ButtonPotionCleanse:
			continue
		button.visible = false
	# Hide most Plant Buttons
	for button in %TabPlants/HBoxContainer/PageButtons/PageButtonList.get_children():
		if button == %ButtonPlantGreenHerbs:
			continue
		button.visible = false
	# Hide most Book Buttons
	for button in %TabBooks/HBoxContainer/PageButtons/PageButtonList.get_children():
		if button == %ButtonBookRawMaterials:
			continue
		button.visible = false
	# NOTE: Ideally, status pages should only get shown if they have been triggered or relevant
	# items/potions have been acquired/crafted.

## Shows the given button and changes the display based on conditions.
func show_button(button : Button):
	button.visible = true

## Sets the visibility of the tab at the given index.
func set_tab_hidden(tab_idx: int, is_hidden: bool = true):
	$VBoxContainer/TabContainer.set_tab_hidden(tab_idx, is_hidden)

## Sets whether the button with the given [param button_name] is hidden.
func set_button_name_visibility(button_name: String, visibility: bool):
	find_child(button_name).visible = visibility

## Returns the node of the page that is currently open in the given tab index.
## If index is -1, gets the currently open tab's open page node.
func get_current_page(tab_index : int =  -1) -> MarginContainer:
	if tab_index == -1:
		tab_index = $VBoxContainer/TabContainer.current_tab
	var inner_tab : TabContainer = $VBoxContainer/TabContainer.get_child(tab_index).get_child(0).get_child(1)
	inner_tab.get_child(inner_tab.current_tab)
	#print(inner_tab.get_child(inner_tab.current_tab).name)
	return inner_tab.get_child(inner_tab.current_tab)

## Adds the current button name to the list of buttons that have been pressed, if not already.
func add_pressed_button_name(button_name: String):
	for b_name in UserVariables.log_book_buttons_pressed:
		if b_name == button_name:
			return
	UserVariables.log_book_buttons_pressed.append(button_name)

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
		ostr += "Times Cut: %s, " % str(UserVariables.objects_cut_interacted[object_name][1])
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

func has_page(page_name: String) -> bool:
	var button_ref : PageButton = find_child("Button%s" % page_name)
	if not button_ref:
		return false
	return true

## Open the page with the [param page_name].
## For instance, "HelpGeneral" opens "PageHelpGeneral".
func open_page(page_name: String) -> bool:
	var button_ref : PageButton = find_child("Button%s" % page_name)
	if not button_ref:
		return false
	if page_name.begins_with("Help"):
		$VBoxContainer/TabContainer.current_tab = 0
	elif page_name.begins_with("RawItem"):
		$VBoxContainer/TabContainer.current_tab = 1
	elif page_name.begins_with("CraftedItem"):
		$VBoxContainer/TabContainer.current_tab = 2
	elif page_name.begins_with("Potion"):
		$VBoxContainer/TabContainer.current_tab = 3
	elif page_name.begins_with("Plant"):
		$VBoxContainer/TabContainer.current_tab = 4
	elif page_name.begins_with("Object"):
		$VBoxContainer/TabContainer.current_tab = 5
	elif page_name.begins_with("Book"):
		$VBoxContainer/TabContainer.current_tab = 6
	elif page_name.begins_with("Place"):
		$VBoxContainer/TabContainer.current_tab = 7
	elif page_name.begins_with("Person"):
		$VBoxContainer/TabContainer.current_tab = 8
	elif page_name.begins_with("Status"):
		$VBoxContainer/TabContainer.current_tab = 9
	else:
		return false
	button_ref.visible = true
	button_ref.button_pressed = true
	button_ref.pressed.emit() # NOTE: Emitting because for some reason button_pressed isn't emitting on previous line.
	return true

## Open the tab with the [param tab_index]. Then call the button press for the page to open.
## In the format: _on_button_"[param button_category_name]"_"[param button_page_name]"_pressed()
func _open_current_page(tab_index: int, button_category_name: String, button_page_name: String):
	$VBoxContainer/TabContainer.current_tab = tab_index
	call("_on_button_%s_%s_pressed" % [button_category_name, button_page_name])

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
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpGeneral")
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
	%PageHelpInteractions/VBoxContainer/LabelToolChange.text = (
		"You can also press \"%s\" to cycle between equipped tools.\n" % 
		InputMap.action_get_events("change_tool")[0].as_text().replace(' - Physical',''))
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpInteractions")
	%PageHelpInteractions.visible = true

##
func open_page_help_tools():
	#%WindowName.text = "Help: Tools"
	%PageHelpTools/VBoxContainer/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+"\" to use the currently held tool on a nearby object.")
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpTools")
	%PageHelpTools.visible = true

## Help pages are already set up,
func open_help_page(page : MarginContainer) -> void:
	if not page.visible:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
	page.visible = true

## Uses template page node to set up the [member current_raw_item] information.
func open_raw_item_page(button_name : String) -> void:#TODO
	if not current_raw_item:
		print("ERROR: No scene currently referenced for plant page.")
		return
	var page : MarginContainer = %PageRawItem
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_raw_item.display_name)
		return
	if not page.visible:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(button_name)
	# Set Descripion
	page.get_child(0).find_child("LabelDescription").text = current_raw_item.description
	# List where you can get the item from
	page.get_child(0).find_child("LabelSources").text = _get_raw_item_sources_as_str()
	# List what to use the item in (if any uses were found)
	page.get_child(0).find_child("LabelUses").text = _get_item_uses_as_str(current_raw_item)
	# List the number of times the item has been consumed/used (or y/n)
	#page.get_child(0).find_child("LabelUseCount").text
	# Set whether to show the details of using the item & effects
	page.get_child(0).find_child("LabelUseText").text = _get_item_use_effects_as_str(current_raw_item)
	
	page.visible = true


func open_raw_item_page_index(idx: int):
	open_raw_item_page(%TabRawItems.find_child("PageButtonList").get_child(idx).name)

##
func _get_raw_item_sources_as_str() -> String:
	var has_source : bool = false
	var sources_str : String = "Known Sources:  "
	for item_id in character_ref.gathered_items.keys():
		if item_id == current_raw_item.id:
			var obj_dict = character_ref.gathered_items[item_id]
			for obj_interaction in obj_dict:
				sources_str += "%s %s, " % [obj_interaction[1], obj_interaction[0]]
				has_source = true
	if has_source:
		sources_str = sources_str.rsplit(",")[0]
	return sources_str

## Returns a [String] of a list of [member Recipe.product_item]s in [member Character.known_recipes]
## and [member Character.objects_combined] that the given [param item] is used in.
func _get_item_uses_as_str(item : Item) -> String:
	var uses_str : String = "Used in: "
	var is_used : bool = false
	# Go through known recipes and find where the item is an ingredient.
	for r : Recipe in character_ref.known_recipes:
		for i : Item in r.ingredients:
			if i.id == item.id:
				uses_str += r.product_item.display_name + ", "
				is_used = true
	
	# Find combinations that the item is used in.
	for obj_name : String in character_ref.objects_combined.keys():
		for combination : ObjectCombination in character_ref.objects_combined[obj_name]:
			if combination != null and combination.input_item.id == item.id:
				uses_str += combination.result_object_scene.instantiate().display_name + ", "
				is_used = true
	
	# Remove the last comma
	if is_used:
		uses_str = uses_str.rsplit(",")[0]
	else:
		uses_str += "Unknown"
	return uses_str

func _get_item_use_effects_as_str(item : Item) -> String:
	var effects_str : String = "Note about consuming: \""
	if not character_ref.has_used_item_id(item.id):
		effects_str += "Item not used yet, no known effects.\""
		return effects_str
	if item.on_consume_message:
		effects_str += item.on_consume_message + "\" | "
	else:
		effects_str += item.on_consume_message + "...\" | "
	if item.on_consume_effects.is_empty():
		effects_str += "No effects."
	else:
		effects_str += "Effects: "
	for se in item.on_consume_effects:
		effects_str += "%s" % se.name
	return effects_str

## Uses template page node to set up the [member current_crafted_item] item information.
func open_crafted_item_page(button_name : String) -> void:
	if not current_crafted_item:
		print("ERROR: No scene currently referenced for plant page.")
		return
	var page : MarginContainer = %PageCraftedItem
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_crafted_item.display_name)
		return
	if not page.visible:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(button_name)
	# Set Descripion
	page.get_child(0).find_child("LabelDescription").text = current_crafted_item.description
	# List where you can get the item from
	page.get_child(0).find_child("LabelSources").text = _get_crafted_item_sources_as_str()
	# List what to use the item in (if any uses were found)
	page.get_child(0).find_child("LabelUses").text = _get_item_uses_as_str(current_crafted_item)
	# Set whether to show the details of using the item & effects
	page.get_child(0).find_child("LabelUseText").text = _get_item_use_effects_as_str(current_crafted_item)
	
	page.visible = true


func open_crafted_item_page_index(idx: int):
	open_crafted_item_page(%TabCraftedItems.find_child("PageButtonList").get_child(idx).name)


func _get_crafted_item_sources_as_str() -> String:
	return "Check Recipe Book for how to craft."

## Uses template page node to set up the [member current_potion] item information.
func open_potion_page(button_name : String) -> void:
	if not current_potion:
		print("ERROR: No scene currently referenced for plant page.")
		return
	var page : MarginContainer = %PagePotion
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_potion.display_name)
		return
	if not page.visible:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(button_name)
	page.get_child(0).find_child("LabelDescription").text = current_potion.description
	# List where you can get the item from
	page.get_child(0).find_child("LabelSources").text = _get_crafted_item_sources_as_str()
	# Set whether to show the details of using the item & effects
	page.get_child(0).find_child("LabelUseText").text = _get_item_use_effects_as_str(current_potion)
	# List the number of times the item has been consumed/used (or y/n)
	page.get_child(0).find_child("LabelMaxUses").text = "Max Uses: " + str(current_potion.max_uses)
	
	page.visible = true


func open_potion_page_index(idx: int):
	open_potion_page(%TabPotions.find_child("PageButtonList").get_child(idx).name)


## Opens the provided page that exists under the plant tab.
## Assumes only one Combine label.
func open_plant_page(page : MarginContainer) -> void:
	if not current_plant_scene:
		print("ERROR: No scene currently referenced for plant page.")
		return
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_plant_scene.display_name)
		return
	if not page.visible:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
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
func open_object_page(page : MarginContainer) -> void:#TODO
	if page.visible:
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
	page.visible = true

##
func open_book_page(page : MarginContainer) -> void:#TODO
	if page.visible:
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
	page.visible = true

##
func open_place_page(page : MarginContainer) -> void:#TODO
	if page.visible:
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
	page.visible = true

##
func open_person_page(page : MarginContainer) -> void:#TODO
	if page.visible:
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(page.name.replace("Page", "Button"))
	page.visible = true

## Uses template page node to set up the [member current_satus_effect] item information.
func open_status_page(button_name : String) -> void:
	if not current_status_effect:
		print("ERROR: No scene currently referenced for status effect page.")
		return
	var page : MarginContainer = %PageStatus
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_status_effect.display_name)
		return
	#if page.visible:
		#return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(button_name)
	page.get_child(0).find_child("LabelDescription").text = current_status_effect.description
	# List where you can get the item from
	var str_value : String = "Potency: "
	if current_status_effect.value == 0:
		str_value += "-"
	else:
		str_value += str(current_status_effect.value)
	page.get_child(0).find_child("LabelValue").text = str_value
	# Set whether to show the details of using the item & effects
	var str_duration : String = "Duration: "
	if current_status_effect.duration == -1:
		str_duration += "Permanent."
	elif current_status_effect.duration == 0:
		str_duration += "Instant."
	else:
		str_duration += str(current_status_effect.duration) + "s."
	page.get_child(0).find_child("LabelDuration").text = str_duration
	
	page.visible = true


func open_status_page_index(idx: int):
	open_status_page(%TabStatuses.find_child("PageButtonList").get_child(idx).name)


##
func open_cutscene_page(button_name : String) -> void:
	if not current_cutscene:
		print("ERROR: No scene currently referenced for cutscene page.")
		return
	var page : MarginContainer = %PageCutscene
	if not page:
		print("ERROR: No page '%s' exists, cannot be opened." % current_cutscene.display_name)
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name(button_name)
	page.get_child(0).texture = current_cutscene
	page.visible = true


func open_cutscene_page_index(idx: int):
	open_cutscene_page(%TabCutscenes.find_child("PageButtonList").get_child(idx).name)


## Loads the currently open page in the given tab.
func open_page_in_tab(tab: int) -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	match tab:
		0: open_help_page(get_current_page(tab))
		1: open_raw_item_page_index(0)
		2: open_crafted_item_page_index(0)
		3: open_potion_page_index(0)
		4: open_plant_page(get_current_page(tab))
		5: open_object_page(get_current_page(tab))
		6: open_book_page(get_current_page(tab))
		7: open_place_page(get_current_page(tab))
		8: open_person_page(get_current_page(tab))
		9: open_status_page_index(0)
		10: open_cutscene_page_index(0)

#####################
### Other Signals ###
#####################

## When the tab is changed, update the currently visible page on the new tab.
func _on_tab_container_tab_changed(tab: int) -> void:
	if not is_node_ready():
		return
	$AudioStreamPlayer.play()
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
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpMP")
	%PageHelpMP.visible = true

func _on_button_help_cauldron_pressed() -> void:
	#%WindowName.text = "Help: Cauldron"
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpCauldron")
	%PageHelpCauldron.visible = true

func _on_button_help_merger_pressed() -> void:
	#%WindowName.text = "Help: Merger"
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "change_page"
	add_pressed_button_name("ButtonHelpMerger")
	%PageHelpMerger.visible = true

### Raw Item Tab ###
####################
func _on_button_item_blue_berries_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/blue_berries.tres")
	open_raw_item_page("ButtonItemBlueBerries")

func _on_button_item_flower_stem_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/flower_stem.tres")
	open_raw_item_page("ButtonItemFlowerStem")

func _on_button_item_green_herb_leaf_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/green_herb_leaf.tres")
	open_raw_item_page("ButtonItemGreenHerbLeaf")

func _on_button_item_red_berries_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/red_berries.tres")
	open_raw_item_page("ButtonItemRedBerries")

func _on_button_item_yellow_petals_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/yellow_petals.tres")
	open_raw_item_page("ButtonItemYellowPetals")

func _on_button_item_crystal_pressed() -> void:
	current_raw_item = load("res://game_systems/items/gatherable/mysterious_crystal.tres")
	open_raw_item_page("ButtonItemCrystal")

### Crafted Item Tab ###
########################
#FIXME: blue juice item does not exist, will throw error.
func _on_button_item_blue_juice_pressed() -> void:
	#current_crafted_item = load("res://game_systems/items/mp_products/blue_juice.tres")
	#open_crafted_item_page(%PageItemBlueJuice)
	print("ERROR: Page not implemented")

func _on_button_item_blue_seed_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/blue_berry_seed.tres")
	open_crafted_item_page("ButtonItemBlueSeed")

func _on_button_item_gray_juice_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/gray_juice.tres")
	open_crafted_item_page("ButtonItemGrayJuice")
#FIXME: gray seed item does not exist, will throw error.
func _on_button_item_gray_seed_pressed() -> void:
	#current_crafted_item = load("res://game_systems/items/mp_products/gray_berry_seed.tres")
	#open_crafted_item_page(%PageItemGraySeed)
	print("ERROR: Page not implemented")

func _on_button_item_green_flakes_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/green_flakes.tres")
	open_crafted_item_page("ButtonItemGreenFlakes")

func _on_button_item_green_paste_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/merged_ingredients/green_paste.tres")
	open_crafted_item_page("ButtonItemGreenPaste")

func _on_button_item_orange_paste_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/merged_ingredients/orange_paste.tres")
	open_crafted_item_page("ButtonItemOrangePaste")

func _on_button_item_red_juice_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/red_juice.tres")
	open_crafted_item_page("ButtonItemRedJuice")

func _on_button_item_red_seed_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/red_berry_seed.tres")
	open_crafted_item_page("ButtonItemRedSeed")

func _on_button_item_saturated_stem_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/merged_ingredients/saturated_stem.tres")
	open_crafted_item_page("ButtonItemSaturatedStem")

func _on_button_item_stem_strands_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/stem_strands.tres")
	open_crafted_item_page("ButtonItemStemStrands")

func _on_button_item_yellow_dust_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/mp_products/yellow_dust.tres")
	open_crafted_item_page("ButtonItemYellowDust")

func _on_button_item_yellow_paste_pressed() -> void:
	current_crafted_item = load("res://game_systems/items/merged_ingredients/yellow_paste.tres")
	open_crafted_item_page("ButtonItemYellowPaste")

### Potion Tab ###
##################
func _on_button_potion_cleanse_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/cleanse_potion.tres")
	open_potion_page("ButtonPotionCleanse")

func _on_button_potion_grow_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/grow_potion.tres")
	open_potion_page("ButtonPotionGrow")

func _on_button_potion_normalize_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/normalize_potion.tres")
	open_potion_page("ButtonPotionNormalize")

func _on_button_potion_shrink_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/shrink_potion.tres")
	open_potion_page("ButtonPotionShrink")

func _on_button_potion_slow_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/slow_potion.tres")
	open_potion_page("ButtonPotionSlow")

func _on_button_potion_speed_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/speed_potion.tres")
	open_potion_page("ButtonPotionSpeed")

func _on_button_potion_strength_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/strength_potion.tres")
	open_potion_page("ButtonPotionStrength")

func _on_button_potion_possession_weak_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/possession_potion_weak.tres")
	open_potion_page("ButtonPotionPossessionWeak")

func _on_button_potion_possession_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/possession_potion.tres")
	open_potion_page("ButtonPotionPossession")

func _on_button_potion_self_attunement_pressed() -> void:
	current_potion = load("res://game_systems/items/potions/self_attunement_potion.tres")
	open_potion_page("ButtonPotionSelfAttunement")

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
	current_object_scene = load("res://level_components/objects/collisions/boulder_pushable.tscn").instantiate()
	open_object_page(%PageObjectBoulder)

func _on_button_object_sliding_door_pressed() -> void:
	current_object_scene = load("res://level_components/objects/triggers/sliding_door_horizontal.tscn").instantiate()
	open_object_page(%PageObjectSlidingDoor)

func _on_button_object_wall_small_hole_pressed() -> void:
	current_object_scene = load("res://level_components/objects/collisions/wall_small_hole.tscn").instantiate()
	open_object_page(%PageObjectWallSmallHole)

func _on_button_object_pressure_plate_pressed() -> void:
	current_object_scene = load("res://level_components/objects/triggers/pressure_plate.tscn").instantiate()
	open_object_page(%PageObjectPressurePlate)

### Book Tab ###
################
func _on_button_book_raw_materials_pressed() -> void:
	#current_book = load("")
	open_book_page(%PageBookRawMaterials)

func _on_button_book_letter_from_r_pressed() -> void:
	#current_book = load("")
	open_book_page(%PageBookLetterFromR)

func _on_button_book_shrink_potion_pressed() -> void:
	#current_book = load("")
	open_book_page(%PageBookShrinkPotion)

func _on_button_book_herb_flakes_pressed() -> void:
	open_book_page(%PageBookHerbFlakes)

func _on_button_book_possession_potion_pressed() -> void:
	open_book_page(%PageBookPossessionPotion)

func _on_button_book_crystal_hint_1_pressed() -> void:
	open_book_page(%PageBookCrystalHint1)

func _on_button_book_crystal_hint_2_pressed() -> void:
	open_book_page(%PageBookCrystalHint2)

func _on_button_book_crystal_hint_3_pressed() -> void:
	open_book_page(%PageBookCrystalHint3)

func _on_button_book_crystal_hint_4_pressed() -> void:
	open_book_page(%PageBookCrystalHint4)

func _on_button_book_crystal_hint_5_pressed() -> void:
	open_book_page(%PageBookCrystalHint5)

### Places Tab ###
##################
func _on_button_places_botania_pressed() -> void:
	open_place_page(%PagePlacesBotania)

### People Tab ###
##################
func _on_button_people_person_1_pressed() -> void: #Placeholder
	open_person_page(%PagePeoplePerson1)

### Status Effects Tab ###
##########################
func _on_button_status_cleanse_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/cleanse.tres")
	open_status_page("ButtonStatusCleanse")

func _on_button_status_energized_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/energized.tres")
	open_status_page("ButtonStatusEnergized")

func _on_button_status_energized_burst_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/energized_burst.tres")
	open_status_page("ButtonStatusEnergizedBurst")

func _on_button_status_grow_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/grow.tres")
	open_status_page("ButtonStatusGrow")

func _on_button_status_normalize_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/normalize.tres")
	open_status_page("ButtonStatusNormalize")

func _on_button_status_self_attunement_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/self_attunement.tres")
	open_status_page("ButtonStatusSelfAttunement")

func _on_button_status_shrink_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/shrink.tres")
	open_status_page("ButtonStatusShrink")

func _on_button_status_slow_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/slow.tres")
	open_status_page("ButtonStatusSlow")

func _on_button_status_strengthen_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/strengthen.tres")
	open_status_page("ButtonStatusStrengthen")

func _on_button_status_possess_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/possess.tres")
	open_status_page("ButtonStatusPossess")

func _on_button_status_possess_weak_pressed() -> void:
	current_status_effect = load("res://game_systems/status_effects/possess_weak.tres")
	open_status_page("ButtonStatusPossessWeak")

### Cutscenes Tab ###
#####################
func _on_button_cutscene_map_1_pressed() -> void: # Cutscene ID 0
	current_cutscene = load("res://art/pack/cutscenes/paper1.png")
	open_cutscene_page("ButtonCutsceneMap1")

func _on_button_cutscene_approaching_ruins_pressed() -> void: # Cutscene 1
	current_cutscene = load("res://art/pack/cutscenes/approaching_ruins.png")
	open_cutscene_page("ButtonCutsceneApproachingRuins")

func _on_button_cutscene_map_2_pressed() -> void: # Cutscene 2
	current_cutscene = load("res://art/pack/cutscenes/paper2.png")
	open_cutscene_page("ButtonCutsceneMap2")

func _on_button_cutscene_enter_ruins_pressed() -> void: # Cutscene 3
	current_cutscene = load("res://art/pack/cutscenes/enter_ruins.png")
	open_cutscene_page("ButtonCutsceneEnterRuins")

func _on_button_cutscene_map_3_pressed() -> void: # Cutscene 4
	current_cutscene = load("res://art/pack/cutscenes/paper3.png")
	open_cutscene_page("ButtonCutsceneMap3")

func _on_button_cutscene_cave_entrance_1_pressed() -> void: # Cutscene 5
	current_cutscene = load("res://art/pack/cutscenes/cave_entrance0.png")
	open_cutscene_page("ButtonCutsceneCaveEntrance1")

func _on_button_cutscene_cave_entrance_2_pressed() -> void: # Cutscene 6
	current_cutscene = load("res://art/pack/cutscenes/cave_entrance1.png")
	open_cutscene_page("ButtonCutsceneCaveEntrance2")

func _on_button_cutscene_discovery_pressed() -> void: # Cutscene 7
	current_cutscene = load("res://art/pack/cutscenes/discovery.png")
	open_cutscene_page("ButtonCutsceneDiscovery")

func _on_button_cutscene_go_home_pressed() -> void: # Cutscene 8
	current_cutscene = load("res://art/pack/cutscenes/go_home.png")
	open_cutscene_page("ButtonCutsceneGoHome")

func _on_button_cutscene_failed_crystal_craft_pressed() -> void: # Cutscene 9
	current_cutscene = load("res://art/pack/cutscenes/failed_crystal_craft.png")
	open_cutscene_page("ButtonCutsceneFailedCrystalCraft")

func _on_button_cutscene_consumed_crystal_pressed() -> void: # Cutscene 10
	current_cutscene = load("res://art/pack/cutscenes/consumed_crystal.png")
	open_cutscene_page("ButtonCutsceneConsumedCrystal")

func _on_button_cutscene_rewind_1_pressed() -> void: # Cutscene 11
	current_cutscene = load("res://art/pack/cutscenes/rewind1.png")
	open_cutscene_page("ButtonCutsceneRewind1")

func _on_button_cutscene_rewind_2_pressed() -> void: # Cutscene 12
	current_cutscene = load("res://art/pack/cutscenes/rewind2.png")
	open_cutscene_page("ButtonCutsceneRewind2")

func _on_button_cutscene_crystal_stabilized_pressed() -> void: # Cutscene 13
	current_cutscene = load("res://art/pack/cutscenes/successful_crystal_craft.png")
	open_cutscene_page("ButtonCutsceneCrystalStabilized")
