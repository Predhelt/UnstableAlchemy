extends LevelManager

## Start a short delay before displaying the cutscene.
func crystal_consumed() -> void:
	$CutsceneDelay.start()

## Plays cutscene for when the crystal is consumed by the player.
func _on_cutscene_delay_timeout() -> void:
	$CutsceneCrystalConsumed.play_cutscene()

## Changes the scene to the first level when the "crystal consumed" cutscene ends.
func _on_cutscene_crystal_consumed_end_scene() -> void:
	Global.change_scene("res://maps/training/1-ruins_entrance.tscn")
