extends NPC

## Keeps track of if the path was already cleared
#var is_path_cleared := false
## Keeps track of if the player has already greeted Brindan
#var has_greeted := false
## Tracks if the saturated stem transaction has been added
#var has_added_saturated_stem := false

#var saturated_stem_ref := preload("res://game_systems/items/merged_ingredients/saturated_stem.tres")
#var red_berries_ref := preload("res://game_systems/items/gatherable/red_berries.tres")
#var flower_stem_ref := preload("res://game_systems/items/gatherable/flower_stem.tres")

## Overrides the _ready function from NPC
#func _ready() -> void:
	#$InteractionArea.interact_type = interaction_type
	#$InteractionArea.interact_label = npc_name
	#%StatusLabel.text = ""
	#%InteractLabel.text = ""
	#init_dialogues()
	#
	## Initialize character statuses based on attributes
	#var cur_se : StatusEffect
	#for i in range(active_status_effects.size()-1, -1, -1):
		#cur_se = active_status_effects[i]
		#active_status_effects.remove_at(i)
		#apply_status_effect(cur_se)

## Determines dialogue based on context. Returns the name of the dialogue window.
func get_initial_dialogue_name(_speakee : Character) -> String:
	## Order of statements matters
	return "greet"

## Called when the player and npc have greeted each other.
#NOTE: If used enough, could be added to parent class
#func finished_greeting():
	#has_greeted = true

## Triggers when the pathway out of the GCSM area is cleared.
## Marks the completion of the level.
#func _on_pathway_cleared():
	#if not is_path_cleared:
		#update_message("Thank you for clearing the path!")
		#is_path_cleared = true
