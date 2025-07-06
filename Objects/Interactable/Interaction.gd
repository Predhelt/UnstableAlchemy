class_name Interaction extends Resource

## DEPRECATED: The name of the interaction type based on which toolwas used by the player to interact with the object.
#@export_enum("grab", "cut") var interaction_name : String
## The items to be received upon interacting (taken out of "items").
@export var on_interact_items : Array[Item] 
## The amount of items to be recieved upon interacting (taken out of "items").
@export var on_interact_amounts : Array[int] 
## StatusEffects that the player receives when the interaction occurs.
@export var on_interact_status_effects : Array[StatusEffect] 
## String identifiers for other effects that occur when the interaction triggers. The player will read these identifiers then execute custom functions.
#@export var on_interact_other_effects : Array[String]
## Message that the player emits relating to the status effects sent when the interaction occurs.
@export var on_interact_status_message := "" 
