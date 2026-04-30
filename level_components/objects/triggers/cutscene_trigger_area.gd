extends Node2D

## Images to be passed to the cutscene for display.
@export var images: Array[Texture2D]

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
