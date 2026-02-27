extends Node2D

var inside_droppables : Array[Area2D]
var item : Item
var texture : Texture2D : 
	set(tex):
		$DragArea/ItemImage.texture = tex
var inventory_menu : Control

func _ready() -> void:
	Global.is_dragging = true
	pass

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("drag_item"):
		if inside_droppables.is_empty(): ## If not in a droppable, put the item back in the inventory.
			inventory_menu.add_inventory_item(item)
		else:
			inside_droppables[0].add_item(item)
		Global.is_dragging = false
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("droppable"):
		inside_droppables.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("droppable"):
		var i := inside_droppables.find(area)
		if i == -1:
			print("Error: Area should be inside the list of droppable objects but was not found.")
		inside_droppables.remove_at(i)
