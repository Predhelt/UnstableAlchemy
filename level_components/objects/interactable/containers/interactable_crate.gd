@tool
extends InteractableObject

@export var contained_item_icon: Texture2D

func _ready() -> void:
	$Sprite2D/ItemIcon.texture = contained_item_icon
	super()
