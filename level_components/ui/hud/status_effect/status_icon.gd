class_name StatusIcon extends Panel

var has_duration : bool
var effect : StatusEffect

## Increments the progress bar every frame.
func _process(delta: float) -> void:
	if Global.mode != &"default":
		return
	if has_duration and $TextureRect/ProgressBar.value < $TextureRect/ProgressBar.max_value:
		$TextureRect/ProgressBar.value += delta

## Uses [param se] info to set up the status icon information.
func reset_effect(se: StatusEffect):
		effect = se
		$TextureRect.texture = se.icon
		if se.duration != -1:
			has_duration = true
			$TextureRect/ProgressBar.max_value = se.duration
			$TextureRect/ProgressBar.value = 0
			$TextureRect/ProgressBar.visible = true
		else:
			has_duration = false
			$TextureRect/ProgressBar.visible = false
		if se.count == -1:
			$TextureRect/Panel.visible = false
		else:
			$TextureRect/Panel.visible = true
			$TextureRect/Panel/LabelCount.text = str(se.count)
