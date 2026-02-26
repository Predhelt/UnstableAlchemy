extends Panel

@onready var player_ref : Player = %Player

func _process(_delta: float) -> void:
	if not visible:
		return
	
	%SpeedData.text = str(player_ref.global_variables.attributes.get_attribute("move speed"))
	%StrengthData.text = str(player_ref.global_variables.attributes.get_attribute("strength"))
	%MassData.text = str(player_ref.global_variables.attributes.get_attribute("mass"))
	%SizeData.text = str(player_ref.global_variables.attributes.get_attribute("size"))
