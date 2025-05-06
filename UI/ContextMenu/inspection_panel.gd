extends PopupPanel

var object_name : StringName = "" :
	set(name):
		$VBoxContainer/HBoxContainer/ObjectName.text = name
var object_description : String = "" :
	set(description):
		$VBoxContainer/ObjectDescription.text = description
var object_image : CompressedTexture2D :
	set(image):
		$VBoxContainer/HBoxContainer/ObjectImage.texture = image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
