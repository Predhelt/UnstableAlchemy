extends Popup

signal confirmed


func _on_button_entered() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"


func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"


func _on_button_confirm_pressed() -> void:
	UserVariables.reset_variables()
	var dir = "user://saves/slot%s" % Global.current_save_slot
	Global.remove_directory(dir)
	DirAccess.remove_absolute("%s.save" % dir)
	confirmed.emit()
	hide()


func _on_button_cancel_pressed() -> void:
	hide()
