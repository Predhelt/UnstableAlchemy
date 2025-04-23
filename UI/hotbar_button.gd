extends Button


func _ready() -> void:
	var event : InputEvent = shortcut.events[0]
	text = event.as_text()
	pressed.connect(_on_pressed)
	
	
func _on_pressed():
	print("test")
