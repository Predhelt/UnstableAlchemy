extends Button

var btn_text : String

func get_btn_text() -> String:
	return $Label.text

func set_btn_text(t : String) -> void:
	$Label.text = t
