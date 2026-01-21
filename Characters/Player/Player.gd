## The playable character
class_name Player extends CharacterBody2D

## Determines the Y offset of the labels above the player
const LABEL_DEFAULT_Y_POS := -60.0
## Value used to reduce the intensity of effects when size is changed
const SIZE_DAMPENER := 0.5

## The tree determing how different animations connect and transition between each other #FIXME: UNUSED
@onready var animation_tree : AnimationTree = $AnimationTree
## Reference to the inventory UI
@onready var inventory_ref : Inventory = %Inventory
## Reference to the camera that is being used to follow the player and display the game screen.
@onready var player_camera_ref : Camera2D = %PlayerCamera

## The direction in 2D space that the character is moving
var direction := Vector2.ZERO

## List of rigid bodies the player is pushing
var pushing_bodies : Array[RigidBody2D]

## The list of status effects that are currently active on the player
var active_status_effects : Array[StatusEffect]

## The list of interaction areas that overlap with the player's reach
var all_interaction_areas : Array[Interactable]
## The time left before the status message disappears
var status_message_timer := 0.0

## The player's stats that determine interactions with the environment
@export var attributes : Attributes
## List of recipes known by the player
@export var known_recipes : Array[Recipe]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
## The currently selected tool that the player is holding
var selected_tool : String

## Set up default UI properties when the player is ready
func _ready() -> void:
	for recipe in known_recipes:
		new_recipes.append(recipe)
	update_interactions()
	%StatusLabel.text = ""

## Every time the player updates, upade the player animations
func _process(_delta: float) -> void:
	update_animation_parameters()

## Update player position and messages every frame
func _physics_process(delta: float) -> void:
	if global.mode == &"default":
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * attributes.move_speed * (Vector2(2.0, 2.0) + 
			(global.player_scale/Vector2(1/SIZE_DAMPENER, 1/SIZE_DAMPENER) - 
				Vector2(SIZE_DAMPENER, SIZE_DAMPENER)))
		move_and_slide()
	
	for rb in pushing_bodies:
		_push_body(rb)
	
	_update_active_status_effect(delta)
	
	if status_message_timer > 0:
		status_message_timer -= delta
		if status_message_timer <= 0:
			%StatusLabel.text = ""
## TODO: Change animations when certain criteria are met
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

## Handles input action events
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		execute_interaction()
	if event.is_action_pressed("use_tool"):
		execute_tool()

## Changes the scale of the player, including size and mass based on the multiplier provided
func change_player_scale(mult: Vector2):
	scale *= mult
	global.player_scale = scale
	## Multiply the current mass by the area of the vector (change in x by change in y)
	attributes.mass *= mult[0] * mult[1]
	attributes.strength *= mult[0] * mult[1]
	
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

## Triggers when an object's interaction area enters the interaction proximity of the player.
func _on_interaction_area_entered(area: Interactable) -> void:
	all_interaction_areas.insert(0, area)
	update_interactions()
	# Outline the object that will be interacted with

## Triggers when an object's interaction area leaves the interaction proximity of the player
func _on_interaction_area_exited(area: Interactable) -> void:
	if area.is_menu_open:
		area.close_context_menu()
	
	all_interaction_areas.erase(area)
	update_interactions()

## Checks if there are any overlapping interaction areas with the player and
## Shows information for an overlapping interaction
func update_interactions():
	if all_interaction_areas:
		%InteractLabel.text = all_interaction_areas[0].interact_label
		# TODO: Add outline to the object that will be interacted with.
	else:
		%InteractLabel.text = ""

## Executes functions on the selected interaction area given the current interaction type
func execute_interaction():
	if all_interaction_areas:
		var cur_interaction = all_interaction_areas[0] # Simple approach
		match cur_interaction.interact_type: # NOTE: When a type is added or updated, it also needs to be changed in Interactable
			&"print_text" : print(cur_interaction.interact_value)
			&"context_menu" : cur_interaction.toggle_context_menu(self) # DEPRECATED
			&"inspect" : cur_interaction.inspect_object()
			&"talk" : cur_interaction.talk()
			&"shop" : cur_interaction.shop()

## Triggers when the tool type is changed. Sets selected_tool as the tool type that was changed.
func _on_tool_updated(tool_name: String) -> void:
	selected_tool = tool_name

## Executes functions on the selected interaction area given the current tool selected.
func execute_tool():
	if all_interaction_areas:
		match selected_tool: # NOTE: If tool type is not set, check that the ToolWheel signal is properly set up
			&"hand" : all_interaction_areas[0].grab_object(self)
			&"blade" : all_interaction_areas[0].cut_object(self)
			&"dropper" : all_interaction_areas[0].combine_object(self, %ToolWheel.dropper_item)

### DEPRECATED
func _on_inventory_update_status_effects(on_consume_effects: Array[StatusEffect], on_consume_message: String) -> void:
	update_status_effects(on_consume_effects, on_consume_message)
###

## Status Effect Handler Methods ##

## Goes through the list of statuses given and adds or updates the active status effects.
## Then, the status message is set above the player if any statuses were successfully added.
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

## Helper function that applies the effects of the status effect to the player based on the effect name.
func _apply_status_effect(se: StatusEffect) -> bool:
	match se.effect:
		&"move speed" :
			attributes.move_speed = _change_attribute(se, attributes.move_speed)
			return true
		&"strength" :
			attributes.strength = _change_attribute(se, attributes.strength)
			return true
		&"cleanse" : if _cleanse_status_effects():
			return true
		&"normalize" : if _normalize_status_effects():
			return true
		&"grow" : if _grow_player(se):
			return true
	return false

## Changes the text of the status message and resets the timer for how long the message appears.
func update_status_message(message: String):
	if not message:
		message = "..."
	%StatusLabel.text = "[center]" + message + "[/center]"
	status_message_timer = 5.0

## Updates the duration of an active status effect based on the amount of time that has passed.
func _update_active_status_effect(delta : float) -> void:
	for i in range(len(active_status_effects)-1, -1, -1):
		var se = active_status_effects[i]
		if se.duration != -1:
			se.duration -= delta
			if se.duration <= 0:
				remove_status_effect(se)

## Removes a given status effect and reverts the changes to the character.
## Returns true if the status effect was successfully removed
func remove_status_effect(se : StatusEffect) -> bool:
	match se.effect:
		&"move speed" : return _change_attribute(se, attributes.move_speed, true)
		&"grow" : return _grow_player(se, true)
	return false

## Updates the images and progress bars on the status bar UI of the given status effect.
## If is_removing_status is true, the status effect will be removed from the status bar.
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

## Adds/subtracts the value of the status effect from the value of an attribute.
## Returns the value after the change from the status effect.
func _change_attribute(se: StatusEffect, _attribute_val: float, is_removing_status := false) -> float:
	for i in len(active_status_effects):
		var cur_se = active_status_effects[i]
		if cur_se.id == se.id:
				
			## Reset the active status effect (New effect overwrites the old effect)
			_attribute_val -= cur_se.value
			
			if is_removing_status:
				update_status_bar(se, i, true)
			else:
				_attribute_val += se.value
				update_status_bar(se, i)
			return _attribute_val
	
	_attribute_val += se.value
	
	update_status_bar(se)
	return _attribute_val

## Removes all status effects that have a limited duration
func _cleanse_status_effects() -> bool:
	for i in range(len(active_status_effects)-1, -1, -1):
		if active_status_effects[i].duration != -1:
			remove_status_effect(active_status_effects[i])
			
	return true

## Removes all status effects that last indefinitely.
func _normalize_status_effects() -> bool:
	for i in range(len(active_status_effects)-1, -1, -1):
		if active_status_effects[i].duration == -1:
			remove_status_effect(active_status_effects[i])
			
	return true

## Increases the size of the player, which also changes other attributes of the character relative to size.
func _grow_player(se: StatusEffect, is_removing_status := false) -> bool:
	for i in len(active_status_effects):
		var cur_se = active_status_effects[i]
		if cur_se.id == se.id:
			# Check if the status effect is already active
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


func _on_rigid_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pushable"):
		if attributes.strength >= body.mass:
			pushing_bodies.append(body)

## Check the mass of the object and compare to the player's strength
## to determine if the player is strong enough to move the body.
func _push_body(body: PhysicsBody2D) -> bool:
	if attributes.strength <= body.mass:
		return false
	## Calculate force based on the strength of the character vs the mass of the body.
	var mult : float
	mult = (attributes.strength - body.mass) / 50
	if mult > 1:
		mult = 1
		
	body.linear_velocity = velocity * mult
	return true

func _on_rigid_area_2d_body_exited(body: Node2D) -> void:
	var i := pushing_bodies.find(body)
	if i != -1:
		pushing_bodies.remove_at(i)
