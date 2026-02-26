extends Node2D

func _ready() -> void:
	var green_flakes := load("res://game_systems/items/mp_products/green_flakes.tres")
	if not %Player.global_variables.inventory.has_item(green_flakes):
		%Player.global_variables.inventory.add_item(green_flakes)
