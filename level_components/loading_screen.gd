extends Control

## List of particles that should be emitted once to prevent lag during gameplay.
var particles : Array[String] = [
	"res://art/effects/object_destroyed_effect.tscn"
]
## Tracks if particles have been emitted already during a load.
var particles_emitted : bool = false

var is_complete: bool = false

signal loading_completed

func _ready() -> void:
	if Global.next_scene_path == "" and not Global.next_scene_path.ends_with(".tscn"):
		print("ERROR: no scene to be loaded")
	$LabelLoadDescription.text = "loading level"
	connect("loading_completed", Global._on_loading_screen_completed)
	ResourceLoader.load_threaded_request(Global.next_scene_path)

func _process(_delta: float) -> void:
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(Global.next_scene_path, progress)
	$HSlider.value = progress[0]*100
	
	if not is_complete and progress[0] == 1:
		is_complete = true
		if not particles_emitted:
			await emit_particles()
			particles_emitted = true
		loading_completed.emit()

## Emit particles during loading so that any first-time emission lag is removed.
func emit_particles() -> bool:
	$LabelLoadDescription.text = "launching particles"
	$HSlider.value = 0
	# Disable SFX audio bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	var num_particles: float = len(particles)
	var cur_particle: GPUParticles2D
	for i in range(num_particles):
		var packed_particle = load(particles[i])
		cur_particle = packed_particle.instantiate()
		add_child(cur_particle)
		await cur_particle.tree_exited #NOTE: Plays each particle until finished.
		$HSlider.value = (i/num_particles)*100
	# Enable SFX audio bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	return true
