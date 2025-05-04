extends CharacterBody2D

const MS = 10 #move speed value

var stats = {
	"health" : 100.0, # health value
	"stamina" : 100.0, # stamina value
	"move speed" : 300.0, # move speed modifier (100 = 1.0*ms)
	"dexterity" : 100.0, # value of speed when interacting with tools
	"strength" : 100.0, # how much can be pushed or carried
	"range" : 100.0, # length of arms
	"height" : 100.0 # height of character
}

# Tools have values that determine the quality of the tool.
# 0 = none, 1 = basic, 2 = refined, 3 = master
var tools = {
	"bare" : 0, # bare hands / appendage
	"pickaxe" : 0, # for mining stone
	"woodcutting axe" : 0, # for cutting trees
	"butterfly net" : 0, # for catching bugs
	"fishing rod" : 0, # for fishing
	"shovel" : 0, # for digging
}


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * stats["move speed"]
	move_and_slide()
	
	# TODO: Change animation when character starts/stops walking
##	if velocity.length() > 0.0:
##		character.play_walk_animation()
##	else:
##		character.play_idle_animation
	
	
