extends UIWindow
var prev_mode : StringName

## Changes the window from opened to closed and vice versa.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Hides the window after removing it from the appropriate group.
func close_window() -> void:
	if global.mode == window_mode:
		global.mode = prev_mode
		global.center_window = null
		prev_mode = ""
		visible = false

## Opens the log book to the default "Help: General" page.
func open_window() -> bool:
	if global.center_window or visible:
		print("Inventory could not be open, " + global.center_window.name + " window already open")
		return false ## Do not open, there is already a window open in the area.
	
	prev_mode = global.mode
	global.mode = window_mode
	global.center_window = self
	#%WindowName.text = "Help: General"
	#$VBoxContainer/TabContainer/TabHelp.visible = true
	visible = true
	#FIXME: Menus in background can prevent tab buttons from being pressed
	open_page_help_general()
	return true

########################################
### Open Pages With Dynamic Elements ###
########################################

### Help Tab ###
func open_page_help_general():
	#%WindowName.text = "Help: General"
	%PageHelpGeneral/VBoxContainer/LabelToolUse.text = ("Walk near a plant or object "+
	"and use a tool on it by pressing \"" +
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+ "\".")
	%PageHelpGeneral/VBoxContainer/LabelInteraction.text = ("You can talk to other characters by pressing \"" +
		InputMap.action_get_events("interact")[0].as_text().replace(' (Physical)','')
		+ "\".")
	
	%PageHelpGeneral.visible = true

func open_page_help_interactions():
	#%WindowName.text = "Help: Interactions"
	%PageHelpInteractions/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" to use the currently held tool on a nearby object.")
	if not InputMap.action_get_events("inspect_object").is_empty():
		%PageHelpInteractions/LabelInspect.text = ("Press \""+
			InputMap.action_get_events("inspect_object")[0].as_text().replace(' (Physical)','')
			+"\" to inspect a nearby object and get a description of it.")
	else:
		%PageHelpInteractions/LabelInspect.text = "(Inspection not currently possible)"
	
	%PageHelpInteractions.visible = true

func open_page_help_tools():
	#%WindowName.text = "Help: Tools"
	%PageHelpTools/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" to use the currently held tool on a nearby object.")
	
	%PageHelpTools.visible = true


## When close button is pressed, close the log book window.
func _on_button_close_pressed() -> void:
	close_window()

####################################################
### Receive Button Presses, Open Associated Page ###
####################################################

### Help Tab ###
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
