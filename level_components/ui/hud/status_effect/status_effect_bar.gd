extends Control

var status_icon_scene = preload("./status_icon.tscn")
@onready var container := $HBoxContainer

func generate_status(se : StatusEffect):
	if update_status(se):
		return
	
	var new_status : StatusIcon = status_icon_scene.instantiate()
	new_status.name = str(se.id)
	new_status.reset_effect(se)
	container.add_child(new_status)

func update_status(se : StatusEffect) -> bool:
	for si : StatusIcon in container.get_children():
		if si.effect.id == se.id:
			si.reset_effect(se) # Resets the timer and icon
			return true
	return false

func remove_status(se : StatusEffect):
	for si in container.get_children():
		if si.name == str(se.id): # Names of status icons are the status effect ID
			si.queue_free()
			return
	print("ERROR: No effect with ID " + str(se.id))
