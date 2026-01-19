@abstract class_name Happening extends Node

## Reference to the npc's Dialogue Tree
var ref_npc_dialogue

## Sets the reference to the NPCDialogue scene for proper function context
func set_npc_dialogue_ref(npc_dialogue) -> void:
	ref_npc_dialogue = npc_dialogue

## Node becomes a child of a NPCDialogue, then executes functions. Implement this function in inherited classes
func execute_functions() -> void:
	pass

## Changes the default dialogue of the npc's dialogue tree
func change_default_dialogue(dialogue_name : String) -> void:
	ref_npc_dialogue.set_default_dialogue(dialogue_name)
	return
