extends Node2D

var is_inside_dropable = false
var item : Item
var texture : Texture2D : 
	set(tex):
		$DragArea/ItemImage.texture = tex
var inventory_ref : Inventory
var area_ref : Area2D

func _ready() -> void:
	global.is_dragging = true
	pass

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("drag_item"):
		if not is_inside_dropable:
			inventory_ref.add_inventory_item(item)
		else:
			area_ref.add_item(item)
		global.is_dragging = false
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Droppable"):
		is_inside_dropable = true
		area_ref = area


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Droppable"):
		is_inside_dropable = false
