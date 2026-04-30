extends Label

func _ready() -> void:
	text = get_tree().current_scene.scene_file_path.split("/")[-1].split(".")[0].replace("_", " ")
