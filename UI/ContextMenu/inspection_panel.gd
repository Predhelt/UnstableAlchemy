extends PopupPanel

@export var item_name : StringName
@export var item_description : String
@export var item_image : CompressedTexture2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HBoxContainer/ItemName.text = item_name
	$VBoxContainer/ItemDescription.text = item_description
	$VBoxContainer/HBoxContainer/ItemImage.texture = item_image
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
