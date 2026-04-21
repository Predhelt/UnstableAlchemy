extends Label

func _ready() -> void:
	text = Global.current_level_path.split("/")[-1].split(".")[0].replace("_", " ")
