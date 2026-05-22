extends LevelManager

## Start a short delay before displaying the cutscene.
func crystal_consumed() -> void:
	$CutsceneDelay.start()

## Plays cutscene for when the crystal is consumed by the player.
func _on_cutscene_delay_timeout() -> void:
	$CutsceneCrystalConsumed.play_cutscene()

## Changes the scene to the first level when the "crystal consumed" cutscene ends.
func _on_cutscene_crystal_consumed_end_scene() -> void:
	UserVariables.has_looped = 1
	Global.change_scene("res://maps/training/1_ruins_entrance.tscn")


func _on_ui_layer_craft_completed(result: Item, _recipe: Recipe) -> void:
	if result.id == 998: # Failed Crystal Craft
		$CutsceneCrystalFailed.play_cutscene()
	#if result.id == 888: # Successful Crystal Craft
		#$CutsceneCrystalSuccess.play_cutscene()

## Changes the scene to the first level when the "crystal failed" cutscene ends.
func _on_cutscene_crystal_failed_end_scene() -> void:
	UserVariables.has_looped = 1
	Global.change_scene("res://maps/training/1_ruins_entrance.tscn")


func _on_cutscene_leave_end_scene() -> void:
	UserVariables.has_looped = 1
	Global.change_scene("res://maps/training/1_ruins_entrance.tscn")


func _on_cutscene_crystal_success_end_scene() -> void:
	$CutsceneCrystalSuccess.play_cutscene()
