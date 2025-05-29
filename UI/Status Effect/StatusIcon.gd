class_name StatusIcon extends TextureRect

var has_duration : bool
var effect : StatusEffect

func _process(delta: float) -> void:
	if has_duration and $ProgressBar.value < $ProgressBar.max_value:
		$ProgressBar.value += delta

func reset_effect(se: StatusEffect):
		effect = se
		texture = se.icon
		if se.duration != -1:
			has_duration = true
			$ProgressBar.max_value = se.duration
			$ProgressBar.value = 0
			$ProgressBar.visible = true
		else:
			has_duration = false
			$ProgressBar.visible = false
