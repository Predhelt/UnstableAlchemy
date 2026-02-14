extends AlchemyTool

func _ready() -> void:
	set_recipes(&"Cauldron")
	#NOTE: Minigame reference and recipes are set in Inventory's _ready function


func _use_items(): ## Overrides the _use_items() function in AlchemyTool
	open_minigame(items.duplicate())
