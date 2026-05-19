@tool
## A portrait for a character Allowing for a [Texture2D] and a character name to be set.
extends Panel

## Tracks whether the portrait is facing to the left or not. By default,
## the image of the portrait should be facing to the right.
## Flips the image horizonally if true.
@export var is_facing_left : bool = false

func _ready() -> void:
	if is_facing_left:
		$MarginContainer/VBoxContainer/TextureRect.flip_h = true

## Sets the portrait of the character to [param portrait].
func set_portrait(portrait : Texture2D) -> void:
	$MarginContainer/VBoxContainer/TextureRect.texture = portrait

## Sets the name / title of the portrait to [param portrait_name].
func set_portrait_name(portrait_name : String) -> void:
	$MarginContainer/VBoxContainer/Label.text = portrait_name
