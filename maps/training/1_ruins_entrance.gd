
extends LevelManager


## Tracks different stages of tutorial messaging

var grabbed_recipe_book: bool = false
var used_recipe_book: bool = false
## Closed inventory after using recipe book
var closed_inventory: bool = false
var opened_recipe_menu: bool = false

func _on_recipe_item_object_grabbed(_body: Character) -> void:
	EventHandler.open_popup_message(
		"Open your bag with %s.
		
		Right-click items in your bag to use them." %
		InputMap.action_get_events("inventory")[0].as_text().replace(' - Physical','')
		)
	grabbed_recipe_book = true
