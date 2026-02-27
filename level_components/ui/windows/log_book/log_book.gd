extends UIWindow
var prev_mode : StringName

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
	
	init_logs(%Player) #NOTE: Rework if user is able to control different characters.
	
	#%WindowName.text = "Help: General"
	#$VBoxContainer/TabContainer/TabHelp.visible = true
	visible = true
	#FIXME: Menus in background can prevent tab buttons from being pressed
	open_page_help_general()
	return true


## Initializes which pages are visible in the log book based on character's stored information.
func init_logs(character : Character) -> void:
	for book_id in character.books_read:
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
	for recipe in character.known_recipes:
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
	pass

func _on_button_item_blue_juice_pressed() -> void:
	#%WindowName.text = "Item: Blue Juice"
	pass

func _on_button_item_blue_seed_pressed() -> void:
	#%WindowName.text = "Item: Blue Seed"
	pass

func _on_button_item_flower_stem_pressed() -> void:
	#%WindowName.text = "Item: Flower Stem"
	pass

func _on_button_item_gray_juice_pressed() -> void:
	#%WindowName.text = "Item: Gray Juice"
	pass

func _on_button_item_gray_seed_pressed() -> void:
	#%WindowName.text = "Item: Gray Seed"
	pass

func _on_button_item_green_flakes_pressed() -> void:
	#%WindowName.text = "Item: Green Flakes"
	pass

func _on_button_item_green_herb_pressed() -> void:
	#%WindowName.text = "Item: Green Herb"
	%PageItemGreenHerb.visible = true

func _on_button_item_green_paste_pressed() -> void:
	#%WindowName.text = "Item: Green Paste"
	pass

func _on_button_item_orange_paste_pressed() -> void:
	#%WindowName.text = "Item: Orange Paste"
	pass

func _on_button_item_red_berries_pressed() -> void:
	#%WindowName.text = "Item: Red Berries"
	%PageItemRedBerries.visible = true

func _on_button_item_red_juice_pressed() -> void:
	#%WindowName.text = "Item: Red Juice"
	pass

func _on_button_item_red_seed_pressed() -> void:
	#%WindowName.text = "Item: Red Seed"
	pass

func _on_button_item_saturated_stem_pressed() -> void:
	#%WindowName.text = "Item: Saturated Stem"
	pass

func _on_button_item_stem_strands_pressed() -> void:
	#%WindowName.text = "Item: Stem Strands"
	pass

func _on_button_item_yellow_dust_pressed() -> void:
	#%WindowName.text = "Item: Yellow Dust"
	pass

func _on_button_item_yellow_paste_pressed() -> void:
	#%WindowName.text = "Item: Yellow Paste"
	pass

func _on_button_item_yellow_petals_pressed() -> void:
	#%WindowName.text = "Item: Yellow Petals"
	pass

### Potion Tab ###
##################
func _on_button_potion_cleanse_pressed() -> void:
	%PagePotionCleanse.visible = true

func _on_button_potion_grow_pressed() -> void:
	pass # Replace with function body.

func _on_button_potion_normalize_pressed() -> void:
	pass # Replace with function body.

func _on_button_potion_shrink_pressed() -> void:
	pass # Replace with function body.

func _on_button_potion_slow_pressed() -> void:
	pass # Replace with function body.

func _on_button_potion_speed_pressed() -> void:
	%PagePotionSpeed.visible = true

func _on_button_potion_strength_pressed() -> void:
	pass # Replace with function body.

### Plant Tab ###
#################
func _on_button_plant_red_berry_bush_pressed() -> void:
	pass # Replace with function body.

func _on_button_plant_green_herbs_pressed() -> void:
	pass # Replace with function body.

func _on_button_plant_yellow_flowers_pressed() -> void:
	pass # Replace with function body.

func _on_button_plant_blue_berry_bush_pressed() -> void:
	pass # Replace with function body.

### Object Tab ###
##################
func _on_button_object_boulder_pressed() -> void:
	pass # Replace with function body.

func _on_button_object_sliding_door_pressed() -> void:
	pass # Replace with function body.

func _on_button_object_crawlspace_pressed() -> void:
	pass # Replace with function body.

func _on_button_object_pressure_plate_pressed() -> void:
	pass # Replace with function body.

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
	pass # Replace with function body.

### People Tab ###
##################
func _on_button_people_person_1_pressed() -> void:
	pass # Replace with function body.
