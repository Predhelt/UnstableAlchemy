extends Node2D

@export var object_name = "Green Herb"
@export var object_description = "A green herb with medicinal properties. Looks pretty normal."
@export var grab_effect : Array[StatusEffect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_interact_area_object_inspected() -> void:
	var inspection_panel = $InteractArea/ContextMenu/MenuContainer/ButtonInspect/InspectionPanel
	inspection_panel.object_name = object_name
	inspection_panel.object_description = object_description
	inspection_panel.object_image = $Sprite2D.texture
	


func _on_interact_area_object_grabbed() -> void: 
	# TODO: Add object to player inventory, remove from map
	pass # Replace with function body.
