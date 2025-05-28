extends Control

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
		if (event.is_action_pressed("ui_cancel")
		or event.is_action_pressed("inventory")
		or event.is_action_pressed("inspect_object")):
			remove_from_group("open_windows")
			global.mode = "default"
			queue_free()
