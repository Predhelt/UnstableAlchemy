class_name Player extends CharacterBody2D

const LABEL_DEFAULT_Y_POS = -60

@onready var animation_tree := $AnimationTree
@onready var inventory_ref := %Inventory

var direction := Vector2.ZERO

var active_status_effects : Array[StatusEffect]

var all_interaction_areas : Array[Area2D]
var status_message_timer := 0.0

var stats = {
	#"health" : 100.0, ## health value
	"move speed" : 200.0, ## move speed modifier (100 = 1.0*ms)
	"strength" : 100.0, ## strength used to move certain objects
	#"range" : 100.0, ## same as CollisionInteract.radius of arms
}

var selected_tool : String


func _ready() -> void:
	update_interactions()
	%StatusLabel.text = ""


func _process(_delta: float) -> void:
	update_animation_parameters()


func _physics_process(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * stats["move speed"] * scale
	move_and_slide()
	
	_update_active_status_effect(delta)
	
	if status_message_timer > 0:
		status_message_timer -= delta
		if status_message_timer <= 0:
			%StatusLabel.text = ""

func update_animation_parameters() -> void:
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	
	if(direction != Vector2.ZERO):
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		execute_interaction()
	if event.is_action_pressed("inspect_object"):
		execute_interaction()
	if event.is_action_pressed("use_tool"):
		execute_tool()
	


## Interaction Methods ##

func _on_interaction_area_entered(area: Interactable) -> void:
	all_interaction_areas.insert(0, area)
	update_interactions()
	# Outline the object that will be interacted with


func _on_interaction_area_exited(area: Interactable) -> void:
	if area.is_menu_open:
		area.close_context_menu()
	
	all_interaction_areas.erase(area)
	update_interactions()


func update_interactions():
	if all_interaction_areas:
		%InteractLabel.text = all_interaction_areas[0].interact_label
		#interact_label.scale = camera_scale
		# TODO: Add outline to the object that will be interacted with
	else:
		%InteractLabel.text = ""


func execute_interaction():
	if all_interaction_areas:
		var cur_interaction = all_interaction_areas[0] # Simple approach
		match cur_interaction.interact_type:
			"print_text" : print(cur_interaction.interact_value)
			"context_menu" : cur_interaction.toggle_context_menu(self)
			"inspect" : cur_interaction.inspect_object()
			"talk" : pass # TODO: talk to NPC


func _on_tool_updated(tool_name: String) -> void:
	selected_tool = tool_name

func execute_tool():
	if all_interaction_areas:
		match selected_tool:
			"hand" : all_interaction_areas[0].grab_object(self)
			"blade" : all_interaction_areas[0].cut_object(self)
			"dropper" : all_interaction_areas[0].combine_object(self, %ToolWheel.dropper_item)


func _on_inventory_update_status_effects(on_consume_effects: Array[StatusEffect], on_consume_message: String) -> void:
	update_status_effects(on_consume_effects, on_consume_message)


func reset_label_height():
	%StatusLabel.position.y = LABEL_DEFAULT_Y_POS * scale[1] - 20
	%InteractLabel.position.y = LABEL_DEFAULT_Y_POS * scale[1] - 45


## Status Effect Handler Methods ##

func update_status_effects(statuses: Array[StatusEffect], message: String):
	# Adds and/or updates the given status effects
	var is_added = false
	for se in statuses:
		if _apply_status_effect(se):
			is_added = true
	if is_added:
		update_status_message(message)

func _apply_status_effect(se: StatusEffect) -> bool:
	match se.effect:
		"change_ms" : if _change_base_stat(se, "move speed"):
			return true
		"cleanse" : if _cleanse_status_effects():
			return true
		"normalize" : if _normalize_status_effects():
			return true
		"grow" : 
			for cur_se in active_status_effects:
				if cur_se.id == se.id:
					return false
			
			if _grow_player(se):
				return true
	return false


func update_status_message(message: String):
	%StatusLabel.text = "[center]" + message + "[/center]"
	status_message_timer = 5.0

func _update_active_status_effect(delta : float) -> void:
	for i in range(len(active_status_effects)-1, -1, -1):
		var se = active_status_effects[i]
		if se.duration != -1:
			se.duration -= delta
			if se.duration <= 0:
				remove_status_effect(se)


func remove_status_effect(se : StatusEffect) -> bool:
	var is_removed := false
	match se.effect:
		"change_ms" : if _change_base_stat(se, "move speed", true):
			is_removed = true
		"grow" : if _grow_player(se, true):
			is_removed = true
	return is_removed

func update_status_bar(se: StatusEffect, index := -1, is_removing_status := false):
	
	if index != -1:
		if is_removing_status:
			active_status_effects.remove_at(index)
			%StatusEffectBar.remove_status(se)
			return
	
	active_status_effects.append(se.duplicate())
	%StatusEffectBar.generate_status(se)


## Status effect functions ##
func _change_base_stat(se: StatusEffect, stat_name : String, is_removing_status := false) -> bool:
	for i in len(active_status_effects):
		var old_se = active_status_effects[i]
		if old_se.id == se.id:
				
			# Reset the active status effect (New effect overwrites the old effect)
			stats[stat_name] -= old_se.value
			
			if is_removing_status:
				update_status_bar(se, i, true)
				return true
			
			stats[stat_name] += se.value
			update_status_bar(se, i)
			return true
	
	stats[stat_name] += se.value
	
	update_status_bar(se)
	return true

func _cleanse_status_effects() -> bool:
	for i in len(active_status_effects):
		if active_status_effects[i].duration != -1:
			remove_status_effect(active_status_effects[i])
			
	return true

func _normalize_status_effects() -> bool:
	for i in len(active_status_effects):
		if active_status_effects[i].duration == -1:
			remove_status_effect(active_status_effects[i])
			
	return true

func _grow_player(se: StatusEffect, is_removing_status := false) -> bool:
	if is_removing_status:
		scale *= Vector2(1.0/se.value, 1.0/se.value)
	else:
		scale *= Vector2(se.value, se.value)
	
	reset_label_height()
	update_status_bar(se, is_removing_status)
	return true
