extends Label

func _ready() -> void:
	#if Global.current_level_path != "":
		#text = Global.current_level_path.split("/")[-1].split(".")[0].replace("_", " ")
	#else:
	text = get_tree().current_scene.scene_file_path.split("/")[-1].split(".")[0].replace("_", " ")
