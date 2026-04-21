extends Label

func _ready() -> void:
	text = ("Press %s to reset level" % 
		InputMap.action_get_events("reset_level")[0].as_text().replace(' - Physical',''))
