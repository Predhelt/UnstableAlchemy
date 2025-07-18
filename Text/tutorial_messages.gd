extends Control

func _ready() -> void:
	$Label2.text = ("Pick up plants with \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" when near them.")
		
	$Label3.text = ("Open your inventory with \""+
		InputMap.action_get_events("inventory")[0].as_text().replace(' (Physical)','')
		+"\".\nOpen your recipe book with \""+
		InputMap.action_get_events("recipe_book")[0].as_text().replace(' (Physical)','')
		+"\".\nUse the Help menu (\"?\" in the top left)
		and known recipes to craft \"Green Flakes\".")
