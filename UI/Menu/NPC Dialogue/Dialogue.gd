class_name Dialogue extends Resource

## Text to be displayed in the dialogue box
@export var text : String
## Mood of the NPC during the dialogue
#@export_enum("happy","mad","sad","neutral") var mood : StringName
## Dialogue choices for the Player and the associated responses
@export var choices : Array[Choice]
