extends CanvasLayer

signal tool_updated(tool_name) ##Connects to Player as _on_tool_updated

func _on_tool_wheel_tool_updated(tool_name: String) -> void:
	tool_updated.emit(tool_name)
