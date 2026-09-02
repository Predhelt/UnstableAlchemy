extends Control

## Next scene to be loaded
var next_scene: String

func _ready() -> void:
	if next_scene == "" and not next_scene.ends_with(".tscn"):
		print("ERROR: no scene to be loaded")
	ResourceLoader.load_threaded_get(next_scene)

func _process(_delta: float) -> void:
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	$HSlider.value = progress[0]*100
