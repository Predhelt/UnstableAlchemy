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
	if Global.mode == window_mode:
		Global.mode = prev_mode
		Global.center_window = null
		prev_mode = ""
		visible = false

func open_window() -> bool:
	if Global.center_window or visible:
		print("Inventory could not be open, " + Global.center_window.name + " window already open")
		return false ## Do not open, there is already a window open in the area.
	
	prev_mode = Global.mode
	Global.mode = window_mode
	Global.center_window = self
	%WindowName.text = "Help: General"
	visible = true
	#FIXME: Menus in background can prevent tab buttons from being pressed
	open_page_general()
	return true


func open_page_general():
	%WindowName.text = "Help: General"
	%PageGeneral/VBoxContainer/LabelToolUse.text = ("Walk near a plant or object "+
	"and use a tool on it by pressing \"" +
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+ "\".")
	%PageGeneral/VBoxContainer/LabelInteraction.text = ("You can talk to other characters by pressing \"" +
		InputMap.action_get_events("interact")[0].as_text().replace(' - Physical','')
		+ "\".")
	%PageGeneral.visible = true

func open_page_interactions():
	%WindowName.text = "Help: Interactions"
	
	%PageInteractions/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
		+"\" to use the currently held tool on a nearby object.")
	if not InputMap.action_get_events("inspect_object").is_empty():
		%PageInteractions/LabelInspect.text = ("Press \""+
			InputMap.action_get_events("inspect_object")[0].as_text().replace(' - Physical','')
			+"\" to inspect a nearby object and get a description of it.")
	else:
		%PageInteractions/LabelInspect.text = "(Inspection not currently possible)"
	
	%PageInteractions.visible = true

func open_page_tools():
	%WindowName.text = "Help: Tools"
	%PageTools.visible = true
	
	%PageTools/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','')
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
