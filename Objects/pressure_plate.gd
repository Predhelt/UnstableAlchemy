extends Node2D

@export var door_refs : Array[Node2D]



func _on_body_entered(_body: Node2D) -> void:
	for door in door_refs:
		door.open_door()


func _on_body_exited(_body: Node2D) -> void:
	for door in door_refs:
		door.close_door()
