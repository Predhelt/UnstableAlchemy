class_name Potion extends Item
# This class currently does not utilize its unique functionality but 

##The number of times left that a single potion can be used
var uses := 0
##The maximum number of uses that a potion can have
var max_uses := 3
##Determines if the potion is able to apply its effects in an area when thrown
var is_splash : bool

func _init() -> void:
	type = "Potion"
