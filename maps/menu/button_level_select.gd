class_name LevelSelectButton extends Button

## File path of the level to be loaded.
@export_file var level_path
## Song name to be played when the level is loaded.
## If no song name is given, continues current song.
@export var song_name: StringName


func _on_pressed() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "press"
	Global.change_scene(level_path)
	MusicManager.change_song(song_name)


func _on_entered() -> void:
	$AudioStreamPlayer.play()
	$AudioStreamPlayer["parameters/switch_to_clip"] = "hover"
