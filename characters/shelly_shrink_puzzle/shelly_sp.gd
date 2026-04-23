extends Character

## Determines dialogue based on context. Returns the name of the dialogue window.
func get_initial_dialogue_name(_speakee : Character) -> String:
	## Order of statements matters
	return "greet"
