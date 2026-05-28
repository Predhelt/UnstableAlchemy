## Boulder that can be pushed by characters if their strength
## smatches or exceeds the mass of the boulder.
extends RigidBody2D

## Saves the object information to file on save if true. Else, is reset upon re-loading.
@export var is_persistent: bool = false

func _ready() -> void:
	if is_persistent:
		add_to_group("Persist")

func save(_dir: String) -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"name" : name,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
		"mass" : mass,
		"is_persistent" : is_persistent,
	}
	return save_dict
