extends Node

## Apply the [param se] to the [param character]. This should not get called currently.
func apply_status_effect(character: Character, se: StatusEffect):
	character.apply_status_effect(se)

## Opens the log book to the [param page_name].
## For instance, "HelpGeneral" opens "PageHelpGeneral".
func open_log_book_page(page_name: String):
	get_tree().current_scene.find_child("LogBookMenu").open_window()
	get_tree().current_scene.find_child("LogBookMenu").open_page(page_name)
