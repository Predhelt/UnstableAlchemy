class_name InteractablePlant extends Resource


@export var object_name := "" ## Name of the object (also the folder name the object is contained in)
@export var object_description := "" ## Description of the object given to the player
@export var items : Array[Item] ## The items that the object contains and their initial quantities

@export var grab_interaction : InteractionType
@export var cut_interaction : InteractionType
@export var combinations : Array[ObjectCombination]

@export var interact_effect : PackedScene = preload("res://Effects/object_interacted_effect.tscn") ## Temporary effect to show during interaction
@export var item_gained_effect : PackedScene = preload("res://Effects/items_gained_effect_world.tscn") ## Show the amount of items gained when added to inventory
