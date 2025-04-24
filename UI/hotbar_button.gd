extends Button

@export var tool : Tool

func _ready() -> void:
	var event : InputEvent = shortcut.events[0]
	text = event.as_text()
	pressed.connect(_on_pressed)
	#TODO: icon.set_button_icon(tool.sprite2d.texture(quality))
	
	
func _on_pressed():
	if tool != null:
		prints(tool.display_name, "Quality: ", tool.quality, "Stats: ", tool.range)
	else:
		print("No tool!")
