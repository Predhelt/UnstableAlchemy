extends InteractableObject


func _ready() -> void:
	super()
	update_petals()

## Override inherited function to check for if the sprite should be changed when grabbed.
func _on_object_grabbed(character: Character) -> void:
	super(character)
	update_petals()

func update_petals() -> void:
	if item_quantities[0] == 0:
		$Sprite2D.texture = load("res://art/pack/objects/planted/yellow_flower_stems.png")
	else:
		$Sprite2D.texture = load("res://art/pack/objects/planted/yellow_flowers.png")
