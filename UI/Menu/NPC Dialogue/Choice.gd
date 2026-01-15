class_name Choice extends Resource
## A choice that the player can make during a particular page of dialogue
## and the events that happen when the choice is made

## The player's response, which is displayed as the dialogue option
@export var player_response : String
## A reference to the name of the dialogue that contains the NPC's response to the player's response
@export var next_dialogue_name : StringName #NOTE: The dialogue is a StringName because directly referencing the Dialogue resource can give a recursion error.
## A list of script paths that are executed when the choice is picked.
@export var happenings : Array[String]
