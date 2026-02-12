class_name Attributes extends Resource
## Health value
#@export var hp := 100.0
## Move speed modifier (100 = 1.0*ms)
@export var base_move_speed := 100.0
## Strength used to move certain objects. 1 STR = 1 KG
@export var base_strength := 100.0
## Determines interactions with environment objects and triggers
@export var base_mass := 100.0
## Represents the size of the character, scaling width and height proportionally.
@export var base_size := 100.0
## Same as CollisionInteract.radius of arms
#@export var range := 100.0

## Attribute modifiers
var size_mult := 1.0
var strength_bonus := 0.0
var move_speed_bonus := 0.0
var mass_bonus := 0.0

## Returns the value of an attribute given the name of the attribute as a String:
## move speed, strength, mass
func get_attribute(att_name : String) -> float:
	match att_name:
		"move speed" : return _get_speed()
		"strength" : return _get_strength()
		"mass" : return _get_mass()
		"size" : return _get_size()
	return -1

## Attribute getters
func _get_size() -> float:
	return base_size * size_mult

func _get_speed() -> float:
	var size_dampener := 0.75 # The higher the value, the less that size impacts this
	return ((_get_size()*(1-size_dampener)+base_move_speed*(size_dampener))*
		(1+(move_speed_bonus/base_move_speed)))

func _get_strength() -> float:
	var size_dampener := 0.5 # The higher the value, the less that size impacts this
	return ((_get_size()*(1-size_dampener)+base_strength*(size_dampener))*
		(1+(strength_bonus/base_strength)))

func _get_mass() -> float:
	return base_mass * (_get_size()/base_size)

## Attribute setters
func set_size_mult(mult : float) -> void:
	size_mult = mult

func set_strength_bonus(bonus : float) -> void:
	strength_bonus = bonus

func set_move_speed_bonus(bonus : float) -> void:
	move_speed_bonus = bonus
	
## Attribute modifiers
func add_size_mult(mult : float) -> void:
	size_mult *= mult

func add_strength_bonus(bonus : float) -> void:
	strength_bonus += bonus

func add_move_speed_bonus(bonus : float) -> void:
	move_speed_bonus += bonus

func add_mass_bonus(bonus : float) -> void:
	mass_bonus += bonus
