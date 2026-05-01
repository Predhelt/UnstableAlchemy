extends RigidBody2D

@export var is_persistent: bool = false

func _ready() -> void:
	if is_persistent:
		add_to_group("Persist")

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"name" : name,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
		"mass" : mass
	}
	return save_dict
