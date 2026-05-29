extends LevelManager

var watched_cutscene: bool = false

func _ready() -> void:
	super()
	if watched_cutscene:
		$Cutscene.hide()


func save(_dir: String) -> Dictionary:
	var save_dict = {
		"watched_cutscene" : watched_cutscene,
	}
	return save_dict


func _on_cutscene_end_scene() -> void:
	watched_cutscene = true
