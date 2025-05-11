class_name Player extends CharacterBody2D

@export var camera_path := "" ## Path from Player Node to the Camera

var active_status_effects : Array[StatusEffect]

@onready var all_interactions : Array[Area2D]
@onready var interact_label := %InteractLabel
@onready var status_message := %StatusLabel
var status_message_timer := 0.0
#@onready var camera_scale = find_child("RemoteTransformCamera").scale

var stats = {
	"health" : 100.0, ## health value
	#"stamina" : 100.0, # stamina value
	"move speed" : 300.0, ## move speed modifier (100 = 1.0*ms)
	#"dexterity" : 100.0, # value of speed when interacting with tools
	"strength" : 100.0, ## how much can be pushed or carried
	#"range" : 100.0, # same as CollisionInteract.radius of arms
	#"height" : 100.0 # same as scale of character
}


func _ready() -> void:
	update_interactions()
	status_message.text = ""



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * stats["move speed"] * scale
	move_and_slide()
	
	update_active_status_effect(delta)
	
	if status_message_timer > 0:
		status_message_timer -= delta
		if status_message_timer <= 0:
			status_message.text = ""
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		execute_interaction()
	
	
	# TODO: Change animation when character starts/stops walking
##	if velocity.length() > 0.0:
##		character.play_walk_animation()
##	else:
##		character.play_idle_animation
	
	

# Interaction Methods

func _on_interaction_area_entered(area: Interactable) -> void:
	all_interactions.insert(0, area)
	update_interactions()
	# Outline the object that will be interacted with
	

func _on_interaction_area_exited(area: Interactable) -> void:
	if area.is_menu_open:
		area.close_context_menu()
	
	all_interactions.erase(area)
	update_interactions()


func update_interactions():
	if all_interactions:
		interact_label.text = all_interactions[0].interact_label
		#interact_label.scale = camera_scale
		# TODO: Add outline to the object that will be interacted with
	else:
		interact_label.text = ""

func execute_interaction():
	if all_interactions:
		var cur_interaction = all_interactions[0]
		match cur_interaction.interact_type:
			"print_text" : print(cur_interaction.interact_value)
			"context_menu" : cur_interaction.toggle_context_menu()


# Status Effect Handler Methods

func update_status_effects(statuses: Array[StatusEffect], message: String):
	for se in statuses:
		add_status_effect(se)
	update_status_message(message)

func update_active_status_effect(delta : float) -> void:
	for i in len(active_status_effects):
		var se = active_status_effects[i]
		se.duration -= delta
		if se.duration <= 0:
			#update_active_status_effect_icon(se) #TODO: make status effect UI and update
			stats[se.player_stat] -= se.value
			active_status_effects.remove_at(i)
		

#func update_active_status_effect_icon()


func add_status_effect(se: StatusEffect) -> void:
	if se.player_stat not in stats:
		print("Error: player stat does not exist")
	
	for i in len(active_status_effects):
		var old_se = active_status_effects[i]
		if old_se.ID == se.ID:
			# Reset the active status effect (New effect overwrites the old effect)
			stats[old_se.player_stat] -= old_se.value
			stats[se.player_stat] += se.value
			active_status_effects.remove_at(i)
			active_status_effects.append(se.duplicate())
			return
	
	stats[se.player_stat] += se.value
	
	active_status_effects.append(se.duplicate())
	# TODO: Show status effect in UI.

func remove_status_effect(se: StatusEffect):
	pass # TODO: When the timer is complete for the status, change the stats back, remove the stat from the UI.

func update_status_message(message: String):
	status_message.text = "[center]" + message + "[/center]"
	status_message_timer = 5.0
