extends TextureRect

var effect : StatusEffect :
	set(effect):
		texture = effect.icon
		$ProgressBar.max_value = effect.duration
		$ProgressBar.value = 0

func _process(delta: float) -> void:
	if $ProgressBar.value >= $ProgressBar.max_value:
		queue_free()
	else:
		$ProgressBar.value += delta
	
