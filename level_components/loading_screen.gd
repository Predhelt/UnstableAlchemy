extends Control

var effect_object_destroyed = preload("res://art/effects/object_destroyed_effect.tscn")
## List of particles that should be emitted once to prevent lag during gameplay.
var particles: Array = [
	effect_object_destroyed
]

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
		if not Global.particles_cached:
			await emit_particles()
			Global.particles_cached = true
		loading_completed.emit()

## Emit particles during loading so that any first-time emission lag is removed.
func emit_particles() -> bool:
	$LabelLoadDescription.text = "launching particles"
	$HSlider.value = 0
	# Disable SFX audio bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	var num_particles: float = len(particles)
	for i in range(num_particles):
		var particle_instance: GPUParticles2D
		particle_instance = particles[i].instantiate()
		particle_instance.set_one_shot(true)
		particle_instance.set_modulate(Color(1,1,1,0.1))
		particle_instance.set_emitting(true)
		add_child(particle_instance)
		await particle_instance.tree_exited #NOTE: Plays each particle until finished.
		$HSlider.value = (i/num_particles)*100
	# Enable SFX audio bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	return true
