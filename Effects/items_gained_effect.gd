extends Control

var item_container : PackedScene = preload("res://Effects/item_gained_container.tscn")

func _physics_process(delta: float) -> void:
	position.y -= delta * 20

func _on_timer_timeout() -> void:
	queue_free()


func item_gained(item: Item, count: int):
	var new_item_container = item_container.instantiate()
	new_item_container.item_icon = item.texture
	new_item_container.item_count = count
	$VBoxContainer.add_child(new_item_container)
