extends NPC

## Keeps track of if the path was already cleared
var is_path_cleared := false

## Overrides the _ready function from NPC
func _ready() -> void:
	$InteractArea.interact_type = interaction_type
	$InteractArea.interact_label = npc_name
	%NPCShop.player = %Player
	self.get_parent().connect("pathway_cleared", _on_pathway_cleared)

## Triggers when the pathway out of the GCSM area is cleared. Marks the completion of the world.
func _on_pathway_cleared():
	if not is_path_cleared:
		update_message("Thank you for clearing the path!")
		is_path_cleared = true
