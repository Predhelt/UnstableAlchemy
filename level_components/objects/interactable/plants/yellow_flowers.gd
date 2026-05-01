extends InteractableObject

## Override inherited function to check for if the sprite should be changed when grabbed.
func _on_object_grabbed(character: Character) -> void:
	super(character)
	if item_quantities[0] == 0:
		$Sprite2D.texture = load("res://art/pack/objects/planted/yellow_flower_stems.png")
