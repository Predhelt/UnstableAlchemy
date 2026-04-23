class_name DialogueChoice extends Resource
## A choice that the player can make during a particular page of dialogue
## and the events that happen when the choice is made

## Any conditions that need to be met for the dialogue to be selectable
@export var conditions : Array[DialogueCondition]
## The player's response, which is displayed as the dialogue option
@export var player_response : String
## A reference to the name of the dialogue that contains the
## character's response to the player's response
@export var next_dialogue_name : StringName #NOTE: The dialogue is a StringName because directly referencing the Dialogue resource can give a recursion error.
## A list of the names of effects that occur when the choice is picked:
## "finished greeting": notifies the character that it has finished greeting the player.
@export var dialogue_effects : Array[String]
