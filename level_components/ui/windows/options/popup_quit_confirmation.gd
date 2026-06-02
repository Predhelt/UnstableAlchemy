extends Popup


func _on_button_entered() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"


func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_cancel_pressed() -> void:
	
	hide()
