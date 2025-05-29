extends Control

var item_container : PackedScene = preload("res://Effects/item_gained_container.tscn")

func _physics_process(delta: float) -> void:
	position.y -= delta * 20

func _on_timer_timeout() -> void:
	queue_free()


func add_item(item: Item, count = -1):
	var new_item_container = item_container.instantiate()
	new_item_container.icon = item.texture
	
	if count == -1:
		new_item_container.count = item.qty
	else:
		new_item_container.count = count
	
	$VBoxContainer.add_child(new_item_container)
