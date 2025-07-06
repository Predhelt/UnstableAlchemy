class_name Item extends Resource

##
## IDs for unique items. -1 is unused. 0-99 are raw ingredients.
## 100-199 are simple produced ingredients. 200-299 are complex ingredients
## that require more than one craft. 500+ are Potions. 999 is the failed craft item
##
@export var id : int
## Name shown to the player.
@export var display_name := ""
## Description shown to the player.
@export var description := "" 
## Image of the item.
@export var texture : Texture2D 
## The maximum amount of the item that can be stacked in one slot in the inventory.
@export var max_qty := 10 
## Tracks the current amount of the item either in the inventory slot or in the object the item is contained in.
@export var qty := 1 
## Status effects that are emitted to the player when the player samples or consumes the item.
@export var on_consume_effects : Array[StatusEffect] 
## The message that the player emits when the item is consumed, relating to the effects of the item.
@export var on_consume_message := "" 

#TODO: Research if item instances should be relative or global
