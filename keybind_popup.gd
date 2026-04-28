## Popup window for when a keybind button is pressed in the settings.
extends PopupPanel
## Emits the binding confirmed by the player
signal set_keybind(bind)


func _on_input_line_text_changed(new_text: String) -> void:
	pass


func _on_button_cancel_pressed() -> void:
	queue_free()


func _on_button_ok_pressed() -> void:
	InputEventFromWindow
	#set_keybind.emit(%KeyPrompt.key)
