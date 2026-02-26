extends Node2D

## Weight required to trigger the pressure plate
@export var trigger_weight : float = 0.0
## The list of doors that are effected by the pressure plate
@export var door_refs : Array[Node2D]

var is_door_open : bool = false


func _on_body_entered(body: Node2D) -> void:
	if body.global_variables.attributes.get_attribute("mass") >= trigger_weight:
		for door in door_refs:
			door.open_door()
			is_door_open = true

func _on_body_exited(_body: Node2D) -> void:
	if is_door_open:
		for door in door_refs:
			door.close_door()
			is_door_open = false
