extends Node2D

var is_dragging := false
var blank_texture := preload("res://Art/UAPrototype/UI/blank_item.png")
var mode := &"default"
var player_scale := Vector2(1.0, 1.0)

#TODO: add items and recipes based on the spreadsheet
#TODO: Remake UI with mobile-first
#TODO: Allow recipe list and inventory/crafting minigame to be open at the same time
