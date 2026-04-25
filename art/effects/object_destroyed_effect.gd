extends GPUParticles2D

## Name of the sound effect to be played upon
var sfx_name : String = ""

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	if sfx_name != "":
		$AudioStreamPlayer2D["parameters/switch_to_clip"] = sfx_name

func _on_timer_timeout() -> void:
	queue_free()
