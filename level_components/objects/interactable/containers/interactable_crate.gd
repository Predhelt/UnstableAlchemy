@tool
extends InteractableObject

@export var contained_item_icon: Texture2D

func _ready() -> void:
	$Sprite2D/ItemIcon.texture = contained_item_icon
	super()
	if item_quantities[0] < 0:
		change_item_count_visibility(false)
	else:
		update_item_count(item_quantities[0])


func save(dir: String) -> Dictionary:
	var save_dict = super(dir)
	save_dict["contained_item_icon"] = var_to_str(contained_item_icon)
	return save_dict

func collect_items(character: Character, interaction: Interaction, sfx_name: StringName) -> bool:
	var b := super(character, interaction, sfx_name)
	update_item_count(item_quantities[0])
	return b

## Changes the count representing how many items are left in the crate.
func update_item_count(count: int):
	$LabelCount.text = str(count)

func change_item_count_visibility(visibility: bool) -> void:
	$LabelCount.visible = visibility
