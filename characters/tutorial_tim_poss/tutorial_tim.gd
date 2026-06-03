extends Character

var has_player_solved: bool = false

## Sets up and returns a [Dictionary] that represents the persistent information
## of the character to be saved to file in [JSON]-compatible format.
func save(dir : String) -> Dictionary:
	var save_dict = super(dir)
	save_dict["has_player_solved"] = has_player_solved
	return save_dict

## Determines dialogue based on context. Returns the name of the dialogue window.
func get_initial_dialogue_name(_speakee : Character) -> String:
	## Order of statements matters
	if has_player_solved:
		if UserVariables.has_looped:
			pass #TODO
		return "congrats"
	if UserVariables.has_looped:
		pass #TODO
	return "greet"
