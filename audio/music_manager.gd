## Manages music of the game.
extends Node

## The song that is currently playing
var current_stream: AudioStream
## Position in the current song.
var current_song_position : float

## Changes the currently playing song to [param song_name].
## To stop playing music, pass the name "none".
#func change_song(song_name: StringName) -> void:
	#if song_name == "" or song_name == current_song:
		#return
	#self["parameters/switch_to_clip"] = song_name
	#play()
	#current_song = song_name

## Pauses the currently playing song.
#func pause() -> void:
	#stream_paused = true

## Resumes the currently playing song without starting from the beginning.
#func resume() -> void:
	#stream_paused = false
