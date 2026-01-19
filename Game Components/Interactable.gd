class_name Interactable extends Area2D

## Sends signal to the parent object when the object is inspected
signal object_inspected()
## Sends signal to the parent object when the object is grabbed
signal object_grabbed(player: Player)
## Sends signal to the parent object when the object is cut
signal object_cut(player: Player)
## Sends signal to the parent object when the object is combined
signal object_combined(player: Player, item: Item)
## Sends signal to the parent object when the npc_talk interaction is received
signal npc_talk()
## Sends signal to the parent object when the npc_shop interaction is received
signal npc_shop()

## The name of the object that is represented by the interactable and shown by the player.
@export var interact_label := "none"
## The type of interaction of the interactable that determines which signal is sent to the object.
@export_enum("none", "print_text", "context_menu", "inspect", "talk", "shop") var interact_type
## An associated string that gets used based on the interaction type.
@export var interact_value := "none"
## Keeps track of if the context menu is open.
var is_menu_open := false
## The scene for creating instances of the context menu
var context_menu_scene = preload("res://UI/Interactable Object/context_menu.tscn")
## The current context menu that is being displayed.
var context_menu : Control

## Context Menu ##

## Changes the visibility of the context menu UI.
func toggle_context_menu(player: Player):
	if not is_menu_open:
		create_context_menu(player)
	else:
		close_context_menu()

## Initializes and displays the context menu UI.
func create_context_menu(player: Player):
	context_menu = context_menu_scene.instantiate()
	add_child(context_menu)
	context_menu.name = interact_value
	context_menu.player = player
	context_menu.create_inspect_button()
	context_menu.connect("object_inspected", _on_object_inspected)
	is_menu_open = true

## Closes the context menu UI and frees it from memory.
func close_context_menu():
	if not context_menu:
		#print("No context menu to close")
		is_menu_open = false
		return
	
	context_menu.queue_free()
	is_menu_open = false

## Object Interactions ##

## Emits signal to object that it was inspected.
func inspect_object() -> void:
	object_inspected.emit()

## Emits signal to object that it was inspected and closes the context menu.
func _on_object_inspected() -> void:
	object_inspected.emit()
	close_context_menu()

## Emits signal to object that it was grabbed.
func grab_object(player: Player) -> void:
	object_grabbed.emit(player)

## Emits signal to object that it was cut.
func cut_object(player: Player) -> void:
	object_cut.emit(player)

## Emits signal to object that it was combined with an item.
func combine_object(player: Player, item: Item) -> void:
	object_combined.emit(player, item)

## Emits signal to object to start talking.
func talk() -> void:
	npc_talk.emit()

## Emits signal to object to start shopping.
func shop() -> void:
	npc_shop.emit()
