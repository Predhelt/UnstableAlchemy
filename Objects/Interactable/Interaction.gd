class_name Interaction extends Resource

#@export_enum("grab", "cut") var interaction_name : String
@export var on_interact_items : Array[Item] ## The items to be received upon interacting (taken out of "items").
@export var on_interact_amounts : Array[int] ## The amount of items to be recieved upon interacting (taken out of "items").
@export var on_interact_status_effects : Array[StatusEffect] ## StatusEffects that the player receives when the interaction occurs
#@export var on_interact_other_effects : Array[String]
@export var on_interact_status_message := "" ## Message that the player emits relating to the status effects sent when the interaction occurs
