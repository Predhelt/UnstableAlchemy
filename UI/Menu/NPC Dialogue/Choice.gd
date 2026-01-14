## A choice that the player can make when 
class_name Choice extends Resource

## The player's response, which is displayed as the dialogue option
@export var player_response : String
## A reference to the name of the dialogue that contains the NPC's response to the player's response
@export var next_dialogue : StringName #NOTE: The dialogue is a StringName because directly referencing the Dialogue resource can give a recursion error.
## Anything that happens when this choice is picked
#@export var happenings : Array[???]#TODO
