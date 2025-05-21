extends TextureRect

var effect : StatusEffect :
	set(se):
		effect = se
		texture = se.icon
		$ProgressBar.max_value = se.duration
		$ProgressBar.value = 0

func _process(delta: float) -> void:
	if $ProgressBar.value < $ProgressBar.max_value:
		$ProgressBar.value += delta
	
