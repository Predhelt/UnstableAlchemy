## Effect for when text is displayed briefly. Plays in the UI, such as inventory or minigame.
extends Control

func _physics_process(delta: float) -> void:
	position.y -= delta * 20

func _on_timer_timeout() -> void:
	queue_free()

## Sets [param txt] to the label's text.
func set_text(txt : String):
	$Label.text = txt
