extends CanvasLayer

## The list of images that will be shown, in the order provided.
@export var images : Array[Texture2D]
## The current index of the panel shown.
var cur_image_index : int
## Play the cutscene when the level loads.
@export var auto_play : bool = false


func _ready() -> void:
	if auto_play:
		play_cutscene()
	else:
		visible = false

## Shows the window and the first image in the cutscene.
func play_cutscene():
	if not images.size() > 0:
		return
	Global.mode = &"cutscene"
	$Panel/TextureRect.texture = images[0]
	cur_image_index = 0
	visible = true

## Shows the next panel in [member panels].
func next_image():
	if cur_image_index < images.size():
		$Panel/TextureRect.texture = images[cur_image_index]
		cur_image_index += 1
	else:
		close_cutscene()

## Closes the cutscene window by freeing the scene, since it will not be reopened.
func close_cutscene():
	Global.mode = &"default"
	queue_free()


func _on_panel_pressed() -> void:
	next_image()
