@tool
extends InteractableObject

@export var contained_item_icon: Texture2D

func _ready() -> void:
	for item in items:
		item_quantities.append(item.qty)
	
	$InteractArea.interact_label = display_name
	$Sprite2D/ItemIcon.texture = contained_item_icon
