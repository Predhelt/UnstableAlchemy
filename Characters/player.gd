extends CharacterBody2D

@export var camera_path : String # Gets path from Player Node, need to add an extra 
# "../" at the beginning of the path name for it to point from the RemoteTransform

@export var status_effects : Array[StatusEffect]
var active_statuses : Array[StatusEffect] = []

@onready var all_interactions = []
@onready var interactLabel = $InteractionComponents/InteractLabel
#@onready var camera_scale = find_child("RemoteTransformCamera").scale



var stats = {
	"health" : 100.0, # health value
	#"stamina" : 100.0, # stamina value
	"move speed" : 300.0, # move speed modifier (100 = 1.0*ms)
	#"dexterity" : 100.0, # value of speed when interacting with tools
	"strength" : 100.0, # how much can be pushed or carried
	#"range" : 100.0, # same as CollisionInteract.radius of arms
	#"height" : 100.0 # same as scale of character
}


func _ready() -> void:
	update_interactions()
	$StatusLabel.text = ""



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * stats["move speed"] * scale
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		execute_interaction()
	
	
	# TODO: Change animation when character starts/stops walking
##	if velocity.length() > 0.0:
##		character.play_walk_animation()
##	else:
##		character.play_idle_animation
	
	

# Interaction Methods

func _on_interaction_area_area_entered(area: Area2D) -> void:
	all_interactions.insert(0, area)
	update_interactions()
	# Outline the object that will be interacted with
	

func _on_interaction_area_area_exited(area: Area2D) -> void:
	var context_menu = area.find_child("ContextMenu")
	if(context_menu):
		context_menu.visible = false
	
	all_interactions.erase(area)
	area.find_child("ContextMenu")
	update_interactions()
	
	

func update_interactions():
	if all_interactions:
		interactLabel.text = all_interactions[0].interact_label
		#interactLabel.scale = camera_scale
		# TODO: Add outline to the object that will be interacted with
	else:
		interactLabel.text = ""

func execute_interaction():
	if all_interactions:
		var cur_interaction = all_interactions[0]
		match cur_interaction.interact_type:
			"print_text" : print(cur_interaction.interact_value)
			"open_context_menu" : toggle_context_menu(cur_interaction, cur_interaction.interact_value)

func toggle_context_menu(interactable : Area2D, menu_name : String):
	var context_menu = interactable.find_child(menu_name)
	if(context_menu):
		if(not context_menu.visible):
			context_menu.visible = true
		else:
			context_menu.visible = false
	else:
		print("Error: No context menu found")

# Status Methods
#TODO: this signal is not being sent or received properly yet
func _on_status_updated(statuses: Array[StatusEffect], status_message: String):
	for status_effect in statuses:
		update_status_effect(status_effect)
	$StatusLabel.text = "[center]" + status_message + "[/center]"

func update_status_effect(se : StatusEffect):
	if se in status_effects:
		if se in active_statuses:
			update_status_effect_active(se)
		else:
			add_status_effect(se)
	else:
		print("Error: Status not in known status list")

func update_status_effect_active(se : StatusEffect):
	pass
	
func add_status_effect(se: StatusEffect):
	pass # TODO: add timer and stat change to character. Show status effect in UI.

func remove_status_effect(se: StatusEffect):
	pass # TODO: When the timer is complete for the status, change the stats back, remove the stat from the UI.
