extends RigidBody2D

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"name" : name,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
	}
	return save_dict
