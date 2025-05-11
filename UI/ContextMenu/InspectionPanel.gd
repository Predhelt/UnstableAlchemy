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
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
