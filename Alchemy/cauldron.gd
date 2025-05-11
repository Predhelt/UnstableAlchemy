extends StaticBody2D

func _process(delta: float) -> void:
	if global.is_dragging:
		scale = Vector2(1.1, 1.1)
	else:
		scale = Vector2(1, 1)
