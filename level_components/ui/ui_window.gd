## Parent class for UI windows
class_name UIWindow extends Control

signal window_opened()
signal window_closed()
## The mode that the window uses when opening. 
## ("menu", "minigame", "dropper", "inspection", "settings", "options")
var window_mode : String

func open_window():
	window_opened.emit()
	
func close_window():
	window_closed.emit()
