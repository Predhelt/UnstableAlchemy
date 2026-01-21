extends Node2D

var blockage_bodies : Array[RigidBody2D]
var is_pathway_blocked := true
signal pathway_cleared()

func _on_blockage_area_2d_body_exited(body: Node2D) -> void:
	if is_pathway_blocked == false:
		return
	
	var i := blockage_bodies.find(body)
	if i != -1:
		blockage_bodies.remove_at(i)
		
		if blockage_bodies.is_empty():
			is_pathway_blocked = false
			pathway_cleared.emit()
	

func _on_blockage_area_2d_body_entered(body: Node2D) -> void:
	if is_pathway_blocked == false:
		is_pathway_blocked = true
	
	blockage_bodies.append(body)
