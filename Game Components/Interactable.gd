class_name Interactable extends Area2D

signal object_grabbed()
signal object_inspected()

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"
var is_menu_open = false

func _ready() -> void:
	$ContextMenu.visible = false


func _on_context_menu_object_inspected() -> void:
	object_inspected.emit()


func _on_context_menu_object_grabbed() -> void:
	object_grabbed.emit()
