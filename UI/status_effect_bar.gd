extends Control

var status_icon_scene = preload("res://UI/StatusEffect/status_icon.tscn")
@onready var container := $HBoxContainer

func generate_status(effect : StatusEffect):
	
	for i in container.get_child_count():
		var se = container.get_child(i)
		if se.ID == effect.ID:
			se.effect = effect # Resets the timer and icon
			return
	
	var new_status = status_icon_scene.instantiate()
	new_status.name = str(effect.ID)
	new_status.effect = effect
	container.add_child(new_status)

func remove_status(effect : StatusEffect):
	for si in container.get_children():
		if si.name == str(effect.ID):
			si.queue_free()
			return
	print("No effect with ID " + str(effect.ID))
