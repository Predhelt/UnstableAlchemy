extends Cutscene

func close_cutscene():
	EventHandler.open_popup_message(
		"Move with WASD keys"
		)
	super()
