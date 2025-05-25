extends Control

var status_icon_scene = preload("res://UI/StatusEffect/status_icon.tscn")
@onready var container := $HBoxContainer

func generate_status(se : StatusEffect):
	
	for textureRect in container.get_children():
		var tex_se = textureRect.effect
		if tex_se.id == se.id:
			tex_se.effect = se.effect # Resets the timer and icon
			return
	
	var new_status = status_icon_scene.instantiate()
	new_status.name = str(se.id)
	new_status.effect = se
	container.add_child(new_status)

func remove_status(se : StatusEffect):
	for si in container.get_children():
		if si.name == str(se.id): # Names of status icons are the status effect ID
			si.queue_free()
			return
	print("No effect with ID " + str(se.id))
