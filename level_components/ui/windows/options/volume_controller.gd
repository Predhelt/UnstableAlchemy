extends Control

## The name of the audio bus being controlled.
@export_enum("Master", "Music", "SFX", "Ambient") var audio_bus_name : String = "Master"


func _ready() -> void:
	match audio_bus_name:
		"Master":
			$HSlider.set_value_no_signal(Global.master_volume)
			$SpinBox.set_value_no_signal(Global.master_volume)
			$LabelChannelName.text = "Master"
		"Music":
			$HSlider.set_value_no_signal(Global.music_volume)
			$SpinBox.set_value_no_signal(Global.music_volume)
			$LabelChannelName.text = "Music"
		"SFX":
			$HSlider.set_value_no_signal(Global.sfx_volume)
			$SpinBox.set_value_no_signal(Global.sfx_volume)
			$LabelChannelName.text = "Sound Effects"
		"Ambient":
			$HSlider.set_value_no_signal(Global.ambient_volume)
			$SpinBox.set_value_no_signal(Global.ambient_volume)
			$LabelChannelName.text = "Ambient"

## Gets the global volume value based on the [member bus_name].
func get_global_volume() -> float:
	match audio_bus_name:
		"Master":
			return Global.master_volume
		"Music":
			return Global.music_volume
		"SFX":
			return Global.sfx_volume
	return -1

## Sets the global volume value based on the [member bus_name].
func set_global_volume(volume: float) -> void:
	match audio_bus_name:
		"Master":
			Global.master_volume = volume
		"Music":
			Global.music_volume = volume
		"SFX":
			Global.sfx_volume = volume


func _on_h_slider_value_changed(value: float) -> void:
	$SpinBox.set_value_no_signal(value)
	set_global_volume(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(audio_bus_name),
		get_global_volume()/100)


func _on_spin_box_value_changed(value: float) -> void:
	$HSlider.set_value_no_signal(value)
	set_global_volume(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(audio_bus_name),
		get_global_volume()/100)
