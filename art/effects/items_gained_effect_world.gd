## Effect for when items are gained. Plays in the world.
extends Control

var item_container : PackedScene = preload("res://art/effects/item_gained_container.tscn")

func _ready() -> void:
	scale = Global.player_scale
	
func _physics_process(delta: float) -> void:
	position.y -= delta * 20 * Global.player_scale[1]
	scale = Global.player_scale

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

## Empties the effect container and puts text indicating that no items were collected.
func set_no_items_gained():
	for child_node in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child_node)
		
	var lbl : Label = Label.new()
	lbl.text = "Cannot collect with current tool!"
	$VBoxContainer.add_child(lbl)
