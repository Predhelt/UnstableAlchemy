class_name Item extends Resource

@export var ID : int
@export var display_name := ""
@export var description := ""
@export var texture : Texture2D
@export var max_qty := 10
@export var qty := 1
@export var on_consume_effects : Array[StatusEffect]
@export var on_consume_message := ""
