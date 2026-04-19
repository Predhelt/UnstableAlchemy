extends Popup


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_cancel_pressed() -> void:
	hide()
