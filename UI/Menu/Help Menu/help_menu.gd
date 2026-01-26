extends UIWindow

## Handles input action events.
#func _input(event: InputEvent) -> void:
	

## Changes the window from opened to closed and vice versa.
func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

## Hides the window after removing it from the appropriate group.
func close_window() -> void:
	global.center_window = null
	if not global.right_window and not global.left_window:
		global.mode = &"default"
	visible = false

func open_window() -> bool:
	if global.center_window or visible:
		print("Inventory could not be open, " + global.center_window.name + " window already open")
		return false ## Do not open, there is already a window open in the area.
	if global.mode == &"default":
		global.mode = window_mode
	if global.mode == window_mode:
		global.center_window = self
		%WindowName.text = "Help: General"
		visible = true
		
		open_page_general()
		return true
	return false


func open_page_general():
	%WindowName.text = "Help: General"
	%PageGeneral/VBoxContainer/LabelToolUse.text = ("Walk near a plant or object "+
	"and use a tool on it by pressing \"" +
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+ "\".")
	%PageGeneral/VBoxContainer/LabelInteraction.text = ("You can talk to other characters by pressing \"" +
		InputMap.action_get_events("interact")[0].as_text().replace(' (Physical)','')
		+ "\".")
	%PageGeneral.visible = true

func open_page_interactions():
	%WindowName.text = "Help: Interactions"
	
	%PageInteractions/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" to use the currently held tool on a nearby object.")
	if not InputMap.action_get_events("inspect_object").is_empty():
		%PageInteractions/LabelInspect.text = ("Press \""+
			InputMap.action_get_events("inspect_object")[0].as_text().replace(' (Physical)','')
			+"\" to inspect a nearby object and get a description of it.")
	else:
		%PageInteractions/LabelInspect.text = "(Inspection not currently possible)"
	
	%PageInteractions.visible = true

func open_page_tools():
	%WindowName.text = "Help: Tools"
	%PageTools.visible = true
	
	%PageTools/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" to use the currently held tool on a nearby object.")

func _on_button_close_pressed() -> void:
	close_window()


func _on_button_general_pressed() -> void:
	open_page_general()


func _on_button_interactions_pressed() -> void:
	open_page_interactions()


func _on_button_tools_pressed() -> void:
	open_page_tools()


func _on_button_mortar_pestle_pressed() -> void:
	%WindowName.text = "Help: Mortar & Pestle"
	%PageMP.visible = true


func _on_button_cauldron_pressed() -> void:
	%WindowName.text = "Help: Cauldron"
	%PageCauldron.visible = true


func _on_button_merger_pressed() -> void:
	%WindowName.text = "Help: Merger"
	%PageMerger.visible = true
