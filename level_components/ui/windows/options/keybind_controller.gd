@tool
extends Control

var keybind_window_ref = preload("res://level_components/ui/windows/options/keybind_popup.tscn")
## The first keybind for input.
var bind1
## The second keybind for input.
var bind2
## The node for the binding that is currently being set, if any.
var cur_node

## Opens a popup window to set the keybind. 
func open_keybind_window():
	var keybind_window : PopupPanel = keybind_window_ref.instantiate()
	add_child(keybind_window)

## Set the input given from the keybind window


func _on_button_binding_1_pressed() -> void:
	open_keybind_window()


func _on_button_binding_2_pressed() -> void:
	pass # Replace with function body.
