extends AlchemyTool

func _ready() -> void:
	set_recipes(&"M&P")

## Find first item in queue to start using in the mortar and pestle,
## Then open the M&P minigame page using the relevant item.
func _use_items(): # Overrides the _use_items() function in AlchemyTool
	for i in MAX_ITEMS:
		if items[i]:
			open_minigame([items[i]]) # Does not remove craft item for testing
			return
