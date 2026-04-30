extends DialogueTrigger

## Override check to start the timer.
## Start the timer if the player enters the area. Message changes depending on
## entering the area without the recipe / flakes, etc.
func _on_body_entered(body: Node2D) -> void:
	if body.is_class("CharacterBody2D") and body.is_camera_focused:
		player_ref = body
		if set_contextual_message():
			start_trigger()
		else:
			player_ref = null

## Sets the message depending on the context.
func set_contextual_message() -> bool:
	if not player_ref.knows_recipe_id(0): # Herb flakes recipe
		if player_ref.inventory.has_item_id(1000): # Herb flakes book
			message = "I should read the book I found"
		else:
			message = "There might be something to help somewhere nearby"
	elif not player_ref.inventory.has_item_id(100): # Herb flakes item
		message = "I should be able to use the recipe to craft something useful"
	else: return false
	return true
