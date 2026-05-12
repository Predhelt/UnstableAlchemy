extends CanvasLayer

var previous_mode : String

## Message to be displayed to the user.
@export_multiline("Message") var message : String

func _ready() -> void:
	previous_mode = Global.mode
	Global.mode = &"popup"
	$Panel/LabelMessage.text = message

func close() -> void:
	Global.mode = previous_mode
	queue_free()

func _on_button_ok_pressed() -> void:
	close()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
