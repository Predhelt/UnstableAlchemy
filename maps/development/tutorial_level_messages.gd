extends Control

func _ready() -> void:
	%LabelInventory.text = ("Open your bag with \"%s\".\nUse items with right-click." %
		InputMap.action_get_events("inventory")[0].as_text().replace(' - Physical',''))
	
	%LabelRecipes.text = ("Open the recipe book with \"%s\".\n
		Check the log book (\"%s\") to get more info." %
		[InputMap.action_get_events("recipe_book")[0].as_text().replace(' - Physical',''),
		InputMap.action_get_events("log_book")[0].as_text().replace(' - Physical','')])


func _process(_delta: float) -> void:
	%LabelInventory.visible = false
	%LabelRecipes.visible = false
	var player : Character = Global.focused_node
	if not player.inventory.has_item_id(100): # Herb flakes ID
		if player.inventory.has_item_id(1000): # Herb flakes book ID
			%LabelInventory.visible = true
		elif player.knows_recipe_id(0): # Herb flakes recipe ID
			%LabelRecipes.visible = true
		
		
		
