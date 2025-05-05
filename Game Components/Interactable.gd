class_name Interactable extends Area2D

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"

signal item_grabbed()

func _ready() -> void:
	$ContextMenu.visible = false


func _on_context_menu_item_grabbed() -> void:
	item_grabbed.emit()
