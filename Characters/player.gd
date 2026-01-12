class_name Player extends CharacterBody2D

const LABEL_DEFAULT_Y_POS := -60.0 ## Determines the Y offset of the labels above the player
const SIZE_DAMPENER := 0.5 ## Value used to reduce the intensity of effects when size is changed

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var inventory_ref : Control = %Inventory
@onready var player_camera_ref : Camera2D = %PlayerCamera

var direction := Vector2.ZERO

var active_status_effects : Array[StatusEffect]

var all_interaction_areas : Array[Interactable]
var status_message_timer := 0.0

var stats = {
	#&"health" : 100.0, ## health value
	&"move speed" : 200.0, ## move speed modifier (100 = 1.0*ms)
	&"strength" : 100.0, ## strength used to move certain objects
	&"mass" : 100.0, ## determines interactions with environments based on weight
	#&"range" : 100.0, ## same as CollisionInteract.radius of arms
}
@export var known_recipes : Array[Recipe] ## Recipes that are known by the player
var new_recipes: Array[Recipe] ## Recipes that have not been viewed yet

var selected_tool : String


func _ready() -> void:
	for recipe in known_recipes:
		new_recipes.append(recipe)
	update_interactions()
	%StatusLabel.text = ""


func _process(_delta: float) -> void:
	update_animation_parameters()


func _physics_process(delta: float) -> void:
	if global.mode == &"default":
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * stats[&"move speed"] * (Vector2(1.0, 1.0) + (global.player_scale/Vector2(1/SIZE_DAMPENER, 1/SIZE_DAMPENER) - Vector2(SIZE_DAMPENER, SIZE_DAMPENER)))
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
	if event.is_action_pressed("use_tool"):
		execute_tool()
	
func change_player_scale(mult: Vector2):
	scale *= mult
	global.player_scale = scale
	
	for node in get_tree().get_nodes_in_group("player_elements"):
		node.scale *= mult
	
	player_camera_ref.zoom *= Vector2(1.0, 1.0)/mult


## Adds the given recipe to the list of known recipes. Returns false if the recipe is already learned
## or true if the recipe is successfully added to the list of known recipes.
func learn_recipe(r: Recipe) -> bool:
	if r in known_recipes:
		return false
	known_recipes.append(r)
	new_recipes.append(r)
	return true


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
		# TODO: Add outline to the object that will be interacted with
	else:
		%InteractLabel.text = ""


func execute_interaction():
	if all_interaction_areas:
		var cur_interaction = all_interaction_areas[0] # Simple approach
		match cur_interaction.interact_type: #NOTE: When a type is added or updated, it also needs to be changed in Interactable
			&"print_text" : print(cur_interaction.interact_value)
			&"context_menu" : cur_interaction.toggle_context_menu(self) #DEPRECATED
			&"inspect" : cur_interaction.inspect_object()
			&"talk" : cur_interaction.talk()
			&"shop" : cur_interaction.shop()


func _on_tool_updated(tool_name: String) -> void:
	selected_tool = tool_name

func execute_tool():
	if all_interaction_areas:
		match selected_tool: #NOTE: If tool type is not set, check that the ToolWheel signal is properly set up
			&"hand" : all_interaction_areas[0].grab_object(self)
			&"blade" : all_interaction_areas[0].cut_object(self)
			&"dropper" : all_interaction_areas[0].combine_object(self, %ToolWheel.dropper_item)

## DEPRECATED
func _on_inventory_update_status_effects(on_consume_effects: Array[StatusEffect], on_consume_message: String) -> void:
	update_status_effects(on_consume_effects, on_consume_message)
##

## Status Effect Handler Methods ##

func update_status_effects(statuses: Array[StatusEffect], message: String):
	# Adds and/or updates the given status effects
	var is_added = false
	for se in statuses:
		if _apply_status_effect(se):
			is_added = true
	if is_added:
		update_status_message(message)
	else:
		update_status_message("...")

func _apply_status_effect(se: StatusEffect) -> bool:
	match se.effect:
		&"move speed" : if _change_base_stat(se, &"move speed"):
			return true
		&"cleanse" : if _cleanse_status_effects():
			return true
		&"normalize" : if _normalize_status_effects():
			return true
		&"grow" : if _grow_player(se):
			return true
	return false


func update_status_message(message: String):
	if not message:
		message = "..."
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
		&"move speed" : if _change_base_stat(se, &"move speed", true):
			is_removed = true
		&"grow" : if _grow_player(se, true):
			is_removed = true
	return is_removed

func update_status_bar(se: StatusEffect, index := -1, is_removing_status := false):
	if index != -1:
		active_status_effects.remove_at(index)
		if is_removing_status:
			%StatusEffectBar.remove_status(se)
			return
		active_status_effects.append(se.duplicate())
		%StatusEffectBar.update_status(se)
		return
	
	active_status_effects.append(se.duplicate())
	%StatusEffectBar.generate_status(se)


## Status effect functions ##
func _change_base_stat(se: StatusEffect, stat_name : String, is_removing_status := false) -> bool:
	for i in len(active_status_effects):
		var cur_se = active_status_effects[i]
		if cur_se.id == se.id:
				
			# Reset the active status effect (New effect overwrites the old effect)
			stats[stat_name] -= cur_se.value
			
			if is_removing_status:
				update_status_bar(se, i, true)
			else:
				stats[stat_name] += se.value
				update_status_bar(se, i)
			return true
	
	stats[stat_name] += se.value
	
	update_status_bar(se)
	return true

func _cleanse_status_effects() -> bool:
	for i in range(len(active_status_effects)-1, -1, -1):
		if active_status_effects[i].duration != -1:
			remove_status_effect(active_status_effects[i])
			
	return true

func _normalize_status_effects() -> bool:
	for i in range(len(active_status_effects)-1, -1, -1):
		if active_status_effects[i].duration == -1:
			remove_status_effect(active_status_effects[i])
			
	return true

func _grow_player(se: StatusEffect, is_removing_status := false) -> bool:
	for i in len(active_status_effects):
		var cur_se = active_status_effects[i]
		if cur_se.id == se.id:
			if se.value == cur_se.value and not is_removing_status:
				return false
			
			change_player_scale(Vector2(1.0/se.value, 1.0/se.value))
			if is_removing_status:
				update_status_bar(se, i, true)
				return true
			
			change_player_scale(Vector2(se.value, se.value))
			update_status_bar(se, i)
			return true
	
	change_player_scale(Vector2(se.value, se.value))
	update_status_bar(se)
	return true
