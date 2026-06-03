extends Popup


func _on_button_entered() -> void:
	if not is_inside_tree():
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"


func _on_button_pressed() -> void:
	if not is_inside_tree():
		return
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"


func _on_button_confirm_pressed() -> void:
	Global.reset_level()


func _on_button_cancel_pressed() -> void:
	hide()
