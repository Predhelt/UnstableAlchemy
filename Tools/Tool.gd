class_name Tool
extends Area2D
## Data representation of the tool

@export var display_name : StringName
@export var quality : int = 0
var range : float = 0.0
var strength : float = 0.0
var speed : float = 0.0



func _ready() -> void:
	if quality == 1:
		range = 50.0
		strength = 50.0
		speed = 50.0
		#TODO: texture swap for rarity
	elif quality == 2:
		range = 100.0
		strength = 100.0
		speed = 100.0
		#TODO: texture swap for rarity
	elif quality == 3:
		range = 150.0
		strength = 150.0
		speed = 150.0
		#TODO: texture swap for rarity
	else:
		quality = 0
		range = 0.0
		strength = 0.0
		speed = 0.0
