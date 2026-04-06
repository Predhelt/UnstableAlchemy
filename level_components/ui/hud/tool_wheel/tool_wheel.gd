extends GridContainer

signal set_dropper_item()

var selected_tool := ""

var has_blade := false
var has_dropper := false

var dropper_icon_full := preload("res://art/pack/tools/dropper_full.png")
var dropper_item : Item:
	set(item):
		dropper_item = item
		if item:
			$CurrentTool.icon = dropper_icon_full
			$CurrentTool/ItemLabel.text = item.display_name

func _ready() -> void:
	$Slot1.button_pressed = true
	$CurrentTool/AddItemButton.visible = false
	tooltip_text = selected_tool
	$CurrentTool/HotkeyLabel.text = (
		InputMap.action_get_events("tool_wheel")[0].as_text().replace(' - Physical',''))
	_close_tool_selection()
	if not has_blade and not has_dropper:
		$CurrentTool/HotkeyLabel.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close_tool_selection()
	if event.is_action_pressed("tool_wheel"):
		toggle_tool_selection()

## Toggle visibility of blade tool slot
func set_blade_enabled(is_enabled : bool) -> void:
	has_blade = is_enabled
	if is_enabled:
		$CurrentTool/HotkeyLabel.visible = true
	elif not has_dropper:
			$CurrentTool/HotkeyLabel.visible = false

## Toggle visibility of dropper tool slot
func set_dropper_enabled(is_enabled : bool) -> void:
	has_dropper = is_enabled
	if is_enabled:
		$CurrentTool/HotkeyLabel.visible = true
	elif not has_blade: # If both tools are not enabled, hide hotkey.
			$CurrentTool/HotkeyLabel.visible = false

func set_tool_to_hand() -> void:
	_on_slot_1_toggled(true)

func _on_slot_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if selected_tool == "hand":
			return
		
		selected_tool = "hand"
		tooltip_text = selected_tool
		if Global.focused_node:
			Global.focused_node.tool_updated("hand")
		$CurrentTool.icon = $Slot1.icon
		toggle_tool_selection()


func _on_slot_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if selected_tool == "blade":
			return
		
		selected_tool = "blade"
		tooltip_text = selected_tool
		if Global.focused_node:
			Global.focused_node.tool_updated("blade")
		$CurrentTool.icon = $Slot2.icon
		toggle_tool_selection()


func _on_slot_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if selected_tool == "dropper":
			return
		
		selected_tool = "dropper"
		tooltip_text = selected_tool
		if Global.focused_node:
			Global.focused_node.tool_updated("dropper")
		$CurrentTool.icon = $Slot3.icon
		toggle_tool_selection()
		$CurrentTool/AddItemButton.visible = true
	
	else:
		dropper_item = null
		$CurrentTool/AddItemButton.visible = false
		$CurrentTool/ItemLabel.text = ""


func _on_current_tool_pressed() -> void:
	toggle_tool_selection()

func toggle_tool_selection() -> void:
	if not has_blade and not has_dropper:
		return
	
	$Slot1.visible = not $Slot1.visible
	if has_blade: $Slot2.visible = not $Slot2.visible
	else: $Slot2.visible = false
	if has_dropper: $Slot3.visible = not $Slot3.visible
	else: $Slot3.visible = false

func _close_tool_selection() -> void:
	$Slot1.visible = false
	$Slot2.visible = false
	$Slot3.visible = false

func _on_add_item_button_pressed() -> void:
	_close_tool_selection()
	set_dropper_item.emit()
