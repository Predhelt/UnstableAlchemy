extends InteractableObject

func _ready() -> void:
	for item in items:
		item_quantities.append(item.qty)
	
	$InteractArea.interact_label = display_name
