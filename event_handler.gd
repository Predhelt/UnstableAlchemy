extends Node

var popup_message_ref : PackedScene = preload("res://level_components/ui/windows/popups/popup_message.tscn")


## Apply the [param se] to the [param character]. This should not get called currently.
func apply_status_effect(character: Character, se: StatusEffect):
	character.apply_status_effect(se)

## Opens the log book to the [param page_name].
## For instance, "HelpGeneral" opens "PageHelpGeneral".
func open_log_book_page(page_name: String):
	if Global.left_window:
		Global.left_window.close_window()
	if Global.right_window:
		Global.right_window.close_window()
	get_tree().current_scene.find_child("LogBookMenu").open_window()
	get_tree().current_scene.find_child("LogBookMenu").open_page(page_name)

## Opens a popup showing the [param message].
func open_popup_message(message: String):
	var popup_message = popup_message_ref.instantiate()
	popup_message.message = message
	get_tree().current_scene.add_child(popup_message)

## Crystal was consumed, play related cutscene then change level back to 1.
## Assumed that the current level is "endings".
func crystal_consumed() -> void:
	get_tree().current_scene.crystal_consumed()

## Player made decision to go home. Plays cutscene for leaving.
## NOTE: Assumes the map has a CutsceneLeave node.
func go_home() -> void:
	var cutscene := get_tree().current_scene.find_child("CutsceneLeave")
	if cutscene:
		cutscene.play_cutscene()

## Opens the designated sliding door in the scene with name "SlidingDoorDialogue"
func open_dialogue_door() -> void:
	var sliding_door := get_tree().current_scene.find_child("SlidingDoorDialogue")
	if sliding_door:
		sliding_door.open_door(Global.focused_node)
