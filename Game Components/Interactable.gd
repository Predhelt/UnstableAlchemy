class_name Interactable extends Area2D

signal object_inspected()
signal object_grabbed(player: Player)
signal object_cut(player: Player)
signal object_combined(player: Player, item: Item)

@export var interact_label := "none"
@export var interact_type := "none"
@export var interact_value := "none"
var is_menu_open := false
var context_menu_scene = preload("res://UI/Context Menu/context_menu.tscn")
var context_menu : ContextMenu

func _ready() -> void:
	pass

func toggle_context_menu(player: Player):
	if not is_menu_open:
		create_context_menu(player)
	else:
		close_context_menu()

func create_context_menu(player: Player):
	context_menu = context_menu_scene.instantiate()
	add_child(context_menu)
	context_menu.name = interact_value
	context_menu.player = player
	context_menu.create_inspect_button()
	context_menu.connect("object_inspected", _on_object_inspected)
	is_menu_open = true

func close_context_menu():
	if not context_menu:
		#print("No context menu to close")
		is_menu_open = false
		return
	
	context_menu.queue_free()
	is_menu_open = false

func inspect_object() -> void:
	object_inspected.emit()

func _on_object_inspected() -> void:
	object_inspected.emit()
	close_context_menu()

func grab_object(player: Player) -> void:
	object_grabbed.emit(player)

func cut_object(player: Player) -> void:
	object_cut.emit(player)

func combine_object(player: Player, item: Item) -> void:
	object_combined.emit(player, item)
