extends Panel

#@onready var player_ref : Character = %Player

func _process(_delta: float) -> void:
	if not visible:
		return
	
	if not Global.focused_node:
		print("ERROR: No node in focus")
		return
	%SpeedData.text = str(Global.focused_node.attributes.get_attribute("move speed"))
	%StrengthData.text = str(Global.focused_node.attributes.get_attribute("strength"))
	%MassData.text = str(Global.focused_node.attributes.get_attribute("mass"))
	%SizeData.text = str(Global.focused_node.attributes.get_attribute("size"))
