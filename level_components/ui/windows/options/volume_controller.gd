@tool
extends Control

## Value of the audio channel (%)
@export var audio_value : float = 80.0
## The name of the audio channel being controlled.
@export_enum("Master", "Music", "SFX") var audio_channel_name : String = "Master"

func _ready() -> void:
	match audio_channel_name:
		"Master": $LabelChannelName.text = "Master"
		"Music": $LabelChannelName.text = "Music"
		"SFX": $LabelChannelName.text = "Sound Effects"
	$HSlider.value = audio_value
	$SpinBox.value = audio_value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(audio_channel_name), audio_value/100)


func _on_h_slider_value_changed(value: float) -> void:
	$SpinBox.set_value_no_signal(value)
	audio_value = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(audio_channel_name), audio_value/100)
	


func _on_spin_box_value_changed(value: float) -> void:
	$HSlider.set_value_no_signal(value)
	audio_value = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(audio_channel_name), audio_value/100)
