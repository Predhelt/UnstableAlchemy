extends GPUParticles2D


func _ready() -> void:
	$AudioStreamPlayer2D.play()

func _on_timer_timeout() -> void:
	queue_free()
