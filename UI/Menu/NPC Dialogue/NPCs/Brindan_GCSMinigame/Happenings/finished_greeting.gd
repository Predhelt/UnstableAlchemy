extends Happening

## When the player has confirmed that they have read the greeting, set the default dialogue
## so that the NPC recognized that they are not greeting the player for the first time.
func execute_functions() -> void:
	change_default_dialogue("re-greet")
