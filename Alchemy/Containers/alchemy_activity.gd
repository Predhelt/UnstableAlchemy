extends Control


var inventory_ref


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_alchemy"):
		toggle_activity() # Toggles whether the inventory is displayed or not
	if event.is_action_pressed("ui_cancel"):
		close_activity()
		
	%Cauldron.inventory_ref = inventory_ref
	%MortarPestle.inventory_ref = inventory_ref

func toggle_activity() -> void:
	visible = !visible # Flip visibility of the inventory

func close_activity() -> void:
	visible = false


func _on_item_produced(recipe: Recipe) -> void:
	%RecipeList.add_recipe(recipe)
