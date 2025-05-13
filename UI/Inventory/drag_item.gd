extends Node2D

var is_inside_dropable = false
var item : Item
var texture : Texture2D : 
	set(tex):
		$DragArea/ItemImage.texture = tex
var inventory_ref : Inventory
var body_ref : Node2D

func _ready() -> void:
	global.is_dragging = true
	pass

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("drag_item"):
		if not is_inside_dropable:
			inventory_ref.add_inventory_item(item)
		else:
			body_ref.add_item(item)
		global.is_dragging = false
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("dropable"):
		is_inside_dropable = true
		body_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("dropable"):
		is_inside_dropable = false
