class_name InspectionPanel extends Control

var object_name : StringName = "" :
	set(name):
		%ObjectName.text = name
var object_description := "" :
	set(description):
		%ObjectDescription.text = description
var object_image : Texture2D :
	set(image):
		%ObjectImage.texture = image


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
	if event.is_action_pressed("ui_toggle_inventory"):
		queue_free()
	if event.is_action_pressed("inspect_object"):
		queue_free()
