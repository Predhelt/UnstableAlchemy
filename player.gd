extends CharacterBody2D

const MS = 200 #move speed value
var held_tool = "bare"

var stats = {
	"health" : 100.0, # health value
	"stamina" : 100.0, # stamina value
	"move speed" : 300.0, # move speed modifier (100 = 1.0*ms)
	"tool speed" : 100.0, # tool speed value (100 = 1.0*ts)
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

var hotbar = { # Determines tool in hotbar slot
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
	
	# Change animation when character starts/stops walking
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

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var eventText : String = event.as_text()
	match eventText:
		"tool_slot1":
			set_tool(1)
		"tool_slot2":
			set_tool(2)
		"tool_slot3":
			set_tool(3)
		"tool_slot4":
			set_tool(4)
		"tool_slot5":
			set_tool(5)
		"tool_slot6":
			set_tool(6)
