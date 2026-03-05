## An interaction that can be performed by a character producing the provided results.
class_name Interaction extends Resource
## The items to be received upon interacting (taken out of "items").
@export var on_interact_items : Array[Item] 
## The amount of items to be recieved upon interacting (taken out of "items").
@export var on_interact_amounts : Array[int] 
## StatusEffects that the player receives when the interaction occurs.
@export var on_interact_status_effects : Array[StatusEffect] 
## Message that the player emits relating to the status effects sent when the interaction occurs.
@export var on_interact_status_message := "" 
