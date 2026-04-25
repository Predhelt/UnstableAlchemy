extends GPUParticles2D

## Name of the sound effect to be played upon
var sfx : AudioStream = null

func _ready() -> void:
	if sfx:
		$AudioStreamPlayer2D.stream.set_clip_stream(1, sfx)
		$AudioStreamPlayer2D["parameters/switch_to_clip"] = "interact"
	$AudioStreamPlayer2D.play()

func _on_timer_timeout() -> void:
	queue_free()
