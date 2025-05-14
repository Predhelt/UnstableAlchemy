extends Control

var status_icon_scene = preload("res://UI/StatusEffect/status_icon.tscn")
@onready var container := $HBoxContainer

func generate_status(effect : StatusEffect):
	
	for i in container.get_child_count():
		var e = container.get_child(i)
		if e.ID == effect.ID:
			e.effect = effect # Resets the timer and icon
			return
	
	var new_status = status_icon_scene.instantiate()
	new_status.effect = effect
	container.add_child(new_status)
