extends Panel


func set_text(message : String) -> void:
	$Label.text = message


func _on_timer_timeout() -> void:
	queue_free()
