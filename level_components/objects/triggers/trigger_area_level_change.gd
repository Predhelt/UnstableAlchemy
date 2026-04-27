extends Area2D

## File path of the level to be loaded.
@export_file var level_path
## Song name to be played when the level is loaded.
## If no song name is given, continues current song.
@export var song_name: StringName

#func _ready() -> void:
	#level_path = level_path.replace('.remap','')

## When player enters the area, load the level being stored.
func _on_body_entered(_body: Node2D) -> void:
	#call_deferred()
	#TODO: Transfer any data that is relevant between levels.
	#(inventory, known_recipes, crafted_recipes, etc.)
	if level_path:
		Global.change_scene(level_path)
		MusicManager.change_song(song_name)
	else:
		print("ERROR: No level path set for scene change.")
