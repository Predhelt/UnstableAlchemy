extends CharacterBody2D

const MS = 200 #move speed value
var held_tool = "bare"

var stats = {
	"health" : 100.0, # health value
	"stamina" : 100.0, # stamina value
	"move speed" : 300.0, # move speed modifier (100 = 1.0*ms)
	"dexterity" : 100.0, # value of speed when interacting with tools
	"strength" : 100.0, # 
	"range" : 100.0, # length of arms
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

var hotbar = { # TODO: Determines tool in hotbar slot
	0 : "bare",
	1 : "pickaxe",
	2 : "woodcutting axe",
	3 : "butterfly net",
	4 : "fishing rod",
	5 : "shovel",
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
	
	


func set_tool(slot: int) -> void:
	if hotbar[slot] != held_tool: # If not holding the selected tool, hold it
		held_tool = hotbar[slot]
	else: # if already holding the tool, deselect it
		held_tool = hotbar[0]
	print(held_tool)
