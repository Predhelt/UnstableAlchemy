class_name PageButton extends Button

var has_been_pressed : bool = false

func _ready() -> void:
	if name.replace("Button", "Page") in UserVariables.pages_opened:
		has_been_pressed = true
		theme = null

func _on_pressed() -> void:
	has_been_pressed = true
	theme = null
