extends GridContainer

signal tool_updated(tool_name: String)
signal set_dropper_item()

var selected_tool := ""

var dropper_icon_full := preload("res://Art/UAPrototype/Tools/dropper-full.png")
var dropper_icon_empty := preload("res://Art/UAPrototype/Tools/dropper.png")
var dropper_item : Item:
	set(item):
		dropper_item = item
		if item:
			$CurrentTool.icon = dropper_icon_full
			$CurrentTool/ItemLabel.text = item.display_name

func _ready() -> void:
	$Slot1.button_pressed = true
	$CurrentTool/AddItemButton.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close_tool_selection()
	#if event.is_action_pressed("open_tool_wheel"):
		#if visible:
			#visible = false
		#else:
			#visible = true


func _on_slot_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected_tool = "hand"
		tool_updated.emit("hand")
		$CurrentTool.icon = $Slot1.icon
		toggle_tool_selection()


func _on_slot_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected_tool = "blade"
		tool_updated.emit("blade")
		$CurrentTool.icon = $Slot2.icon
		toggle_tool_selection()


func _on_slot_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected_tool = "dropper"
		tool_updated.emit("dropper")
		$CurrentTool.icon = $Slot3.icon
		toggle_tool_selection()
		$CurrentTool/AddItemButton.visible = true
	else:
		dropper_item = null
		$CurrentTool/AddItemButton.visible = false


func _on_current_tool_pressed() -> void:
	toggle_tool_selection()

func toggle_tool_selection() -> void:
	$Slot1.visible = not $Slot1.visible
	$Slot2.visible = not $Slot2.visible
	$Slot3.visible = not $Slot3.visible

func _close_tool_selection() -> void:
	$Slot1.visible = false
	$Slot2.visible = false
	$Slot3.visible = false

func _on_add_item_button_pressed() -> void:
	set_dropper_item.emit()
