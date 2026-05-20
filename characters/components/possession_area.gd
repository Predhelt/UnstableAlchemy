extends Area2D

func _ready():
	disable_collision()

## Enable the collision shape and show collision area visuals if character is in focus.
func enable_collision():
	$CollisionShape2D.disabled = false
	if get_parent().is_camera_focused:
		visible = true

## Disable the collision shape and hide collision area visuals.
func disable_collision():
	$CollisionShape2D.disabled = true
	visible = false
