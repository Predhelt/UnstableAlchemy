@tool
## A pressure plate that when stood on, sends an open command to any [member door_refs].
## Pressure plates connect to sliding doors to open them. Depending on the
## door configuration, multiple pressure plates may be needed to trigger a door to open.
extends Node2D

## The texture for the pressure plate sprite.
@export var texture : Texture2D
## Weight required to trigger the pressure plate.
@export var trigger_weight : float = 0.0
## The list of doors that are effected by the pressure plate.
@export var door_refs : Array[Node2D]

## List of [Node2D]'s that are on the pressure plate.
var bodies : Array[Node2D]

func _ready() -> void:
	$Sprite2D.texture = texture

func _process(_delta: float) -> void:
	var mass_sum : float = 0.0
	for b in bodies:
		if b.is_class("CharacterBody2D"):
			mass_sum += b.attributes.get_attribute("mass")
		else:
			mass_sum += b.mass
	if mass_sum >= trigger_weight:
		for door in door_refs:
			door.open_door(self)
	if mass_sum < trigger_weight:
		for door in door_refs:
			door.close_door(self)

func _on_body_entered(body: Node2D) -> void:
	bodies.append(body)

func _on_body_exited(body: Node2D) -> void:
	bodies.remove_at(bodies.find(body))
