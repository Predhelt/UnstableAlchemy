class_name Interactable extends Area2D

## Sends signal to the parent object when the object is inspected
signal object_inspected()
## Sends signal to the parent object when the object is grabbed
signal object_grabbed(character: Character)
## Sends signal to the parent object when the object is cut
signal object_cut(character: Character)
## Sends signal to the parent object when the object is combined
signal object_combined(character: Character, item: Item)
## Sends signal to the parent object when the npc_talk interaction is received
signal character_talk()
## Sends signal to the parent object when the npc_shop interaction is received
signal character_shop()

## The name of the object that is represented by the interactable and shown by the character.
@export var interact_label := "none"
## The type of interaction of the interactable that determines which signal is sent to the object.
@export_enum("none", "print_text", "inspect", "talk", "shop") var interact_type : String
## An associated string that gets used based on the interaction type.
@export var interact_value := "none"
## Keeps track of if the context menu is open.
var is_menu_open := false

## Object Interactions ##

## Emits signal to object that it was inspected.
func inspect_object() -> void:
	object_inspected.emit()

## Emits signal to object that it was inspected.
func _on_object_inspected() -> void:
	object_inspected.emit()

## Emits signal to object that it was grabbed.
func grab_object(character: Character) -> void:
	object_grabbed.emit(character)

## Emits signal to object that it was cut.
func cut_object(character: Character) -> void:
	object_cut.emit(character)

## Emits signal to object that it was combined with an item.
func combine_object(character: Character, item: Item) -> void:
	object_combined.emit(character, item)

## Emits signal to object to start talking.
func talk(character: Character) -> void:
	if character.is_camera_focused:
		character_talk.emit()

## Emits signal to object to start shopping.
func shop() -> void:
	character_shop.emit()
