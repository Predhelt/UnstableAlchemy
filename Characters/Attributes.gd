class_name Attributes extends Resource
## Health value
#@export var hp := 100.0
## Move speed modifier (100 = 1.0*ms)
@export var move_speed := 100.0
## Strength used to move certain objects. 1 STR = 1 KG
@export var strength := 100.0
## Determines interactions with environment objects and triggers
@export var mass := 100.0
## Same as CollisionInteract.radius of arms
#@export var range := 100.0

## Returns the value of an attribute given the name of the attribute as a String:
## move speed, strength, mass
func get_attribute(att_name : String) -> float:
	match att_name:
		"move speed" : return move_speed
		"strength" : return strength
		"mass" : return mass
	return -1
