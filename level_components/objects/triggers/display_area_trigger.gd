extends Node

@export var display_scene : Node2D
@onready var player_ref : Character = %Player

func _ready() -> void:
	if display_scene:
		display_scene.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not display_scene:
		return
	
	if body == player_ref:
		display_scene.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not display_scene:
		return
	
	if body == player_ref:
		display_scene.visible = false
