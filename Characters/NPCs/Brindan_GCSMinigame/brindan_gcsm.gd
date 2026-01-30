extends NPC

## Keeps track of if the path was already cleared
var is_path_cleared := false
## Keeps track of if the player has already greeted Brindan
var has_greeted := false


## Overrides the _ready function from NPC
func _ready() -> void:
	$InteractArea.interact_type = interaction_type
	$InteractArea.interact_label = npc_name
	%StatusLabel.text = ""
	%InteractLabel.text = ""
	init_dialogues()

## Determines dialogue based on context. Returns the name of the dialogue window.
func get_initial_dialogue_name(speakee : Character) -> String:
	## Order of statements matters
	if is_path_cleared:
		return "thanks"
	if speakee.get_attribute("strength") >= 150:
		return "player_is_strong"
	if speakee.inventory.has_item(506): # Strength Potion ID
		return "player_has_strength_potion"
	if speakee.knows_recipe_id(506): # Strength Potion ID
		return "player_knows_strength_potion"
	if has_greeted:
		return "re-greet"
	return "greet"

## Called when the player and npc have greeted each other.
#NOTE: If used enough, could be added to parent class
func finished_greeting():
	has_greeted = true

## Triggers when the pathway out of the GCSM area is cleared.
## Marks the completion of the level.
func _on_pathway_cleared():
	if not is_path_cleared:
		update_message("Thank you for clearing the path!")
		is_path_cleared = true
