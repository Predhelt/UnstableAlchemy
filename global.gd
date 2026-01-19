extends Node2D
## Tracks if an item is being dragged by the mouse / cursor.
var is_dragging := false
## Keeps reference of the blank texture that is used when another texture is not available.
var blank_texture := preload("res://Art/UAPrototype/UI/blank_item.png")
## Keeps track of the state that the game is in to determine what types of actions are allowed.
var mode := &"default"
## Tracks the current absolute size and mass of the player.
var player_scale := Vector2(1.0, 1.0)

## Keeps track of the window on the left side of the screen
var left_window : Control
## Keeps track of the window on the right side of the screen
var right_window : Control
## Keeps track of the window in the center of the screen
var center_window : Control

## Checks input action events and closes a window.
## Closes the center window, or right, or left, respectively.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if center_window:
			center_window.close_window()
		elif right_window:
			right_window.close_window()
		elif left_window:
			left_window.close_window()

#TODO: add items and recipes based on the spreadsheet
#TODO: Remake UI with mobile-first
