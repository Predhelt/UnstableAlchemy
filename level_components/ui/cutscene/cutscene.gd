class_name Cutscene extends CanvasLayer

signal end_scene

## The list of images that will be shown, in the order provided.
@export var images : Array[Texture2D]
## The list of cutscene IDs to use to track which cutscenes have been watched.
## References to which cutscene IDs refer to which images can be found in the log book script.
@export var cutscene_ids : Array[int]
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
	#var has_watched_cutscene: bool = true
	#for id in cutscene_ids:
		#if id not in UserVariables.cutscenes_watched:
			#has_watched_cutscene = false
	#if has_watched_cutscene:
		#return
	
	Global.mode = &"cutscene"
	$Panel/TextureRect.texture = images[0]
	cur_image_index = 1
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
	for id in cutscene_ids:
		if id not in UserVariables.cutscenes_watched:
			UserVariables.cutscenes_watched.append(id)
	Global.mode = &"default"
	end_scene.emit()
	queue_free()


func _on_panel_pressed() -> void:
	next_image()
