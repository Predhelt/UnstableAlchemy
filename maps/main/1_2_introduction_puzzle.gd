extends Node2D

func _ready() -> void:
	var item : Item = load("res://game_systems/items/mp_products/green_flakes.tres")
	if %Player.global_variables.inventory.has_item(item):
		%Player.global_variables.inventory.remove_items([item], [0], true)
	item = load("res://game_systems/items/potions/speed_potion.tres")
	if %Player.global_variables.inventory.has_item(item):
		%Player.global_variables.inventory.remove_items([item], [0], true)
