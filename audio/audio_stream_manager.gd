extends Node

func _ready() -> void:
	if MusicManager.current_stream == $MusicAudioStream.stream:
		$MusicAudioStream.play(MusicManager.current_song_position)


## Pauses the currently playing song.
func pause_music() -> void:
	$MusicAudioStream.stream_paused = true

## Resumes the currently playing song without starting from the beginning.
func resume_music() -> void:
	$MusicAudioStream.stream_paused = false
