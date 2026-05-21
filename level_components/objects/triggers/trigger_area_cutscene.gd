extends Node2D

signal end_scene

## Images to be passed to the cutscene for display.
@export var images: Array[Texture2D]
## The list of cutscene IDs to use to track which cutscenes have been watched.
## References to which cutscene IDs refer to which images can be found in the log book script.
@export var cutscene_ids : Array[int]

var triggers_doors: AnimatableBody2D
## Tracks whether the player has watched the cutscene already.
var has_watched: bool = false

func _ready() -> void:
	$Cutscene.images = images

## Checks if the body that entered has the focus of the camera and displays the cutscene.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_camera_focused and not has_watched:
		$Cutscene.play_cutscene()
		has_watched = true


func _on_cutscene_end_scene() -> void:
	for id in cutscene_ids:
		if id not in UserVariables.cutscenes_watched:
			UserVariables.cutscenes_watched.append(id)
	end_scene.emit()
