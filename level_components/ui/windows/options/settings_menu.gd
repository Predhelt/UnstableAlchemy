extends Window

func _ready() -> void:
	# Tabs are not hidden or disabled when exported if only set in editor, so this is to confirm.
	$TabContainer.set_tab_hidden(1, true)
	$TabContainer.set_tab_hidden(4, true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_requested()


func _on_close_requested() -> void:
	Global.mode = &"default"
	hide()


func _on_about_to_popup() -> void:
	Global.mode = &"settings"


func update_keybind_messages():
	get_tree().call_group("KeybindMessageHandler", "refresh_input_messages")


func _on_controls_keybind_changed() -> void:
	update_keybind_messages()
