class_name Dialogue extends Resource

## Internal name of the dialogue
@export var dialogue_name : StringName
## Text to be displayed in the dialogue box
@export_multiline var text : String
## Mood of the NPC during the dialogue
#@export_enum("happy","mad","sad","neutral") var mood : StringName
## Dialogue choices for the Player and the associated responses
@export var choices : Array[Choice]
## Keeps track of if each choice has already been selected by the player
#@export var were_chosen : Array[bool] #TODO

#func _init() -> void:
	#for i in choices.size():
		#were_chosen.append(false)
