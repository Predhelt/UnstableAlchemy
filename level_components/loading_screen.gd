extends Control

## List of particles that should be emitted once to prevent lag during gameplay.
var particles : Array[String] = [
	"res://art/effects/object_destroyed_effect.tscn"
]
## Tracks if particles have been emitted already during a load.
var particles_emitted : bool = false

signal loading_completed

func _ready() -> void:
	if Global.next_scene_path == "" and not Global.next_scene_path.ends_with(".tscn"):
		print("ERROR: no scene to be loaded")
	$LabelLoadDescription.text = "loading level"
	connect("loading_completed", Global._on_loading_screen_completed)
	print(ResourceLoader.load_threaded_request(Global.next_scene_path))

func _process(_delta: float) -> void:
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(Global.next_scene_path, progress)
	$HSlider.value = progress[0]*100
	
	if progress[0] == 1:
		if not particles_emitted:
			emit_particles()
		loading_completed.emit()

## Emit particles durin loading so that any first-time emission lag is removed.
func emit_particles():
	$LabelLoadDescription.text = "launching particles"
	$HSlider.value = 0
	var num_particles : float = len(particles)
	var cur_particle : PackedScene
	for i in range(len(particles)):
		cur_particle = load(particles[i])
		cur_particle.instantiate()
		$HSlider.value = (i/num_particles)*100
	particles_emitted = true
