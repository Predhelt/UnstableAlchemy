extends CanvasLayer

## Message to be displayed to the user.
@export_multiline("Message") var message : String

func _ready() -> void:
	#Global.mode = &"popup"
	$Panel/LabelMessage.text = message


func _on_button_ok_pressed() -> void:
	queue_free()
