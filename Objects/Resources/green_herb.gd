extends Node2D

@export var item_name = "Green Herb"
@export var item_description = "A green herb with medicinal properties. Looks pretty normal."
#@export var 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact_area_object_grabbed() -> void: 
	# TODO: Add item/object to player inventory, remove from map
	pass # Replace with function body.
