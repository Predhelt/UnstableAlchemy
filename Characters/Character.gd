## A 2D Character with attributes, an inventory, animations, movement, known recipes, etc.
## Status effects can be applied to the character, which can effect how the character
## can be controlled by the player or how the character interacts with the environment.
class_name Character extends CharacterBody2D

## References to UI Nodes that the Character may access.
@onready var se_bar_ref = $"../UILayer/HUDLayer/StatusEffectBar"
@onready var status_label_ref = %StatusLabel
@onready var interact_label_ref = %InteractLabel
@onready var tool_wheel_ref = $"../UILayer/HUDLayer/ToolWheel"
@onready var attribute_display_ref = $"../UILayer/HUDLayer/AttributeDisplay"


## Determines the Y offset of the labels above the character
const LABEL_DEFAULT_Y_POS := -60.0
## Value used to reduce the intensity of effects when size is changed
const SIZE_DAMPENER := 0.5

## The tree determing how different animations connect and transition between each other 
@onready var animation_tree : AnimationTree = $AnimationTree
## Path of the file containing the global variables of the current character, if any.
#@export var global_variables : CharacterVariables
## Reference to the camera that is being used to follow the character and display the game screen.
@export var character_camera_ref : Camera2D

## The character's base stats that determine interactions with the environment
@export var attributes : Attributes
## List of recipes known by the character. This is mainly used internally for keeping
## track of the character-specific knowledge, not the player's known recipes.
## Player-known recipes are stored in UserVariables.
@export var known_recipes : Array[Recipe]
## Keys: IDs of items that have been gathered from interactable objects like plants.
## Values: Number of times gathered.
var gathered_items : Dictionary[int, int]
## List of books by ID that the character has read
var books_read : Array[int]

## Reference to the inventory resource of the character(s).
@export var inventory : Inventory
## The list of status effects that are currently active on the character
@export var active_status_effects : Array[StatusEffect]
## Tracks whether the character is being controlled by the player
var is_player_controlled : bool = false
## Tracks whether the camera is focused on the character
var is_camera_focused : bool = false

## The direction in 2D space that the character is moving
var direction := Vector2.ZERO
## List of rigid bodies the character is pushing
var pushing_bodies : Array[RigidBody2D]
## List of crawlspace bodies that the character is occupying.
var crawlspace_bodies : Array[StaticBody2D]
## The list of interaction areas that overlap with the character's reach
var all_interaction_areas : Array[Interactable]
## The time left before the status message disappears
var status_message_timer := 0.0
## The currently selected tool that the character is holding
var selected_tool : StringName = &"hand"

## Set up default UI properties when the character is ready
func _ready() -> void:
	
	status_label_ref.text = ""
	interact_label_ref.text = ""
	#%HotkeyLabel.text = ""
	
	# Should only be 1 reference to a camera in the scene.
	if character_camera_ref != null:
		set_camera()
		#for recipe in known_recipes:
			#UserVariables.new_recipes.append(recipe)
	
	## Initialize character statuses based on attributes
	var cur_se : StatusEffect
	for i in range(active_status_effects.size()-1, -1, -1):
		cur_se = active_status_effects[i]
		active_status_effects.remove_at(i)
		apply_status_effect(cur_se)

func set_camera() -> void:
	is_player_controlled = true
	is_camera_focused = true
	Global.focused_node = self
	Global.focused_camera = character_camera_ref
	# Set up camera transform
	var camera_transform : RemoteTransform2D = load("res://level_components/player_camera_transform.tscn").instantiate()
	camera_transform.remote_path = character_camera_ref.get_path()
	add_child(camera_transform)

## Update character position and messages every frame
func _physics_process(delta: float) -> void:
	if Global.mode != &"default":
		return
	
	if is_player_controlled:
		_move_character(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	
	for rb in pushing_bodies:
		_push_body(rb)
	
	_update_status_effect_timers(delta)

	if status_message_timer > 0:
		status_message_timer -= delta
		if status_message_timer <= 0:
			status_label_ref.text = ""

## Handles input action events. Only accepts inputs when the player is controlling the character.
func _input(event: InputEvent) -> void:
	if not is_player_controlled:
		return
	if event.is_action_pressed("interact"):
		if Global.mode == &"default": ## Only execute interaction in appropriate mode
			execute_interaction()
	if event.is_action_pressed("use_tool"):
		if Global.mode == &"default": ## Only execute tool in appropriate mode
			execute_tool()
	if event.is_action_pressed("inspect_object"):
		if Global.mode == &"default":
			inspect_object()

## Every time the character updates, upade the character animations
func _process(_delta: float) -> void:
	update_animation_parameters()

## Helper function that takes a direction vector and calculates character motion.
func _move_character(vector : Vector2) -> void:
	if Global.mode == &"default":
		direction = vector
		velocity = direction * attributes.get_attribute("move speed") * 2 # base speed too slow, doubles it.
		move_and_slide()

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

## Sets up and returns a dictionary that represents the persistent information
## of the character to be saved to file.
func save() -> Dictionary:
	var cur_path : String = "user://save/characters/%s" % name
	if not DirAccess.dir_exists_absolute(cur_path):
		DirAccess.make_dir_recursive_absolute(cur_path)
	
	ResourceSaver.save(attributes, "%s/attributes.tres" % cur_path)
	ResourceSaver.save(inventory, "%s/inventory.tres" % cur_path)
	
	if(not active_status_effects.is_empty() and 
			not DirAccess.dir_exists_absolute("%s/status_effects" % cur_path)):
		DirAccess.make_dir_absolute("%s/status_effects" % cur_path)
	for se in active_status_effects:
		print(ResourceSaver.save(se, "%s/status_effects/%s.tres" % [cur_path,se.name]))
	
	var save_dict = {
		"filename" : get_scene_file_path(),
		"name" : name,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
		"attributes_path" : "user://save/characters/%s/attributes.tres" % name,
		"inventory_path" : "user://save/characters/%s/inventory.tres" % name,
		"known_recipes" : known_recipes,
		"gathered_items" : gathered_items,
		"books_read" : books_read,
		"active_status_effects_path" : "user://save/characters/%s/status_effects/" % name,
		"is_player_controlled" : is_player_controlled,
		"is_camera_focused" : is_camera_focused,
		#"selected_tool" : selected_tool
	}
	return save_dict

## Used to call the get_attribute function of Attributes
## without needing to access the attributes variable.
func get_attribute(att_name : String) -> float:
	return attributes.get_attribute(att_name)

## Adds the given recipe to the list of known recipes. Returns false if the recipe is already learned
## or true if the recipe is successfully added to the list of known recipes.
## if is_crafted is true, will add to the count of succesful recipe crafts.
func learn_recipe(r: Recipe, is_crafted:bool = false) -> bool:
	if is_camera_focused:
		UserVariables.add_recipe(r)
		if is_crafted:
			if not UserVariables.crafted_recipes.has(r.id):
				UserVariables.crafted_recipes[r.id] = 1 ## Add key to dictionary
			else:
				UserVariables.crafted_recipes[r.id] += 1 ## iterate on key in dictionary
	if r in known_recipes:
		return false
	known_recipes.append(r)
	return true

## Returns whether or not the character knows a recipe with the given item as the product.
func knows_recipe(item: Item) -> bool:
	for r in known_recipes:
		if r.product_item.id == item.id:
			return true
	return false

## Returns whether or not the character knows a recipe with the given item id as the product.
func knows_recipe_id(item_id: int) -> bool:
	for r in known_recipes:
		if r.product_item.id == item_id:
			return true
	return false

## marks the book as "read" and learns any associated recipes in the book.
func read_book(book: Book):
	for recipe in book.recipes:
		learn_recipe(recipe)
	if not book.id in books_read:
		books_read.append(book.id)
	if is_camera_focused and book.id in UserVariables.books_read:
		UserVariables.books_read.append(book.id)

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
		#TODO: Smarter way to choose an interaction near the player.
		var cur_interaction : Interactable = all_interaction_areas[0]
		interact_label_ref.text = cur_interaction.interact_label
		#if is_player_controlled:
			#if str(cur_interaction.interact_type) == "talk" or str(cur_interaction.interact_type) == "shop":
				#%HotkeyLabel.text = (
					#"(" + InputMap.action_get_events("interact")[0].as_text().replace(' - Physical','') + ")")
			#else:
				#%HotkeyLabel.text = (
					#"(" + InputMap.action_get_events("use_tool")[0].as_text().replace(' - Physical','') + ")")
		# TODO: Add outline to the object that will be interacted with.
	else:
		interact_label_ref.text = ""
		#%HotkeyLabel.text = ""

## Executes functions on the selected interaction area given the current interaction type
func execute_interaction():
	if all_interaction_areas:
		var cur_interaction = all_interaction_areas[0] # Simple approach
		match cur_interaction.interact_type: # NOTE: When a type is added or updated, it also needs to be changed in Interactable
			&"print_text" : print(cur_interaction.interact_value)
			#&"context_menu" : cur_interaction.toggle_context_menu(self) # DEPRECATED
			&"inspect" : cur_interaction.inspect_object()
			&"talk" : cur_interaction.talk(self)
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
			&"dropper" : all_interaction_areas[0].combine_object(self, tool_wheel_ref.dropper_item)

## Open the inspection panel for an object in the interaciton area
func inspect_object():
	if all_interaction_areas:
		var cur_interaction := all_interaction_areas[0] #TODO: Function to do smart selection of nearby areas.
		cur_interaction.inspect_object()

## Status Effect Handler Methods ##

## Goes through the list of statuses given and adds or updates the active status effects.
## Then, the status message is set above the player if any statuses were successfully added.
func update_status_effects(statuses: Array[StatusEffect], message: String):
	# Adds and/or updates the given status effects
	var is_added = false
	for se in statuses:
		if apply_status_effect(se):
			is_added = true
	if is_added:
		update_status_message(message)
	else:
		update_status_message("...")

## Helper function that applies the status effect to the player based on the effect name.
func apply_status_effect(se: StatusEffect) -> bool:
	match se.effect:
		&"move speed bonus" : return _add_attribute_bonus(se, attributes.add_move_speed_bonus)
		&"strength bonus" : return _add_attribute_bonus(se, attributes.add_strength_bonus)
		&"cleanse" : return _cleanse_status_effects()
		&"normalize" : return _normalize_status_effects()
		&"grow" : return _grow_character(se)
		&"self-attunement" : return _attune_self(se)
	return false

## Changes the text of the status message and resets the timer for how long the message appears.
func update_status_message(message: String):
	if not message:
		message = "..."
	status_label_ref.text = "[center]" + message + "[/center]"
	status_message_timer = 5.0

## Updates the duration of an active status effect based on the amount of time that has passed.
func _update_status_effect_timers(delta : float) -> void:
	for i in range(active_status_effects.size()-1, -1, -1):
		var se = active_status_effects[i]
		if se.duration != -1:
			se.duration -= delta
			if se.duration <= 0:
				remove_status_effect(se)

## Removes a given status effect at the given index in active_status_effects 
## and reverts the changes to the character.
## Returns true if the status effect was successfully removed
func remove_status_effect(se : StatusEffect) -> bool:
	match se.effect:
		&"move speed bonus" : return _add_attribute_bonus(se, attributes.add_move_speed_bonus, true)
		&"grow" : return _grow_character(se, true)
		&"strength bonus" : return _add_attribute_bonus(se, attributes.add_strength_bonus, true)
		&"self-attunement" : return _attune_self(se, true)
	return false

## Updates the images and progress bars on the status bar UI of the given status effect.
## If is_removing_status is true, the status effect will be removed from the status bar.
func update_status_bar(se: StatusEffect, index := -1, is_removing_status := false) -> void:
	if index != -1:
		active_status_effects.remove_at(index)
		if is_removing_status:
			se_bar_ref.remove_status(se)
			return
		active_status_effects.append(se.duplicate())
		se_bar_ref.update_status(se)
		return
	
	active_status_effects.append(se.duplicate())
	se_bar_ref.generate_status(se)


### Status effect functions ###

## Takes the status effect and adds its value to the given callable Attributes function.
## For instance, attributes.add_move_speed_bonus(se) or attributes.add_strength_bonus(se).
## If is_removing is true, removes the status effect from the status bar and list of active statuses.
func _add_attribute_bonus(se : StatusEffect, c : Callable, is_removing : bool = false) -> bool:
	var se_index := _get_se_index(se)
	if  se_index == -1:
		if not is_removing:
			c.call(se.value)
			update_status_bar(se)
			return true
		else:
			print("ERROR: No status effect " + se.name + " Currently active to remomve. Returning false.")
			return false
	else:
		if not is_removing:
			c.call(se.value)
		else:
			c.call(-se.value)
		update_status_bar(se, se_index, is_removing)
		return true

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

## Increases the size of the player, 
## which also changes other attributes of the character relative to size.
func _grow_character(se: StatusEffect, is_removing_status := false) -> bool:
	var se_index : int = _get_se_index(se)
	if se_index == -1: ## If status effect not already applied:
		attributes.add_size_mult(se.value)
		set_character_scale(attributes.get_attribute("size"))
		update_status_bar(se)
		return true
	
	if se.value == active_status_effects[se_index].value and not is_removing_status:
		return false
	
	attributes.add_size_mult(1.0/se.value)
	
	if is_removing_status:
		set_character_scale(attributes.get_attribute("size"))
		update_status_bar(se, se_index, true)
		return true
	
	attributes.add_size_mult(se.value)
	set_character_scale(attributes.get_attribute("size"))
	update_status_bar(se, se_index)
	return true

## Compares the ID of the status effect to the array of active status effects
## Returns the index of the status effect, -1 if not found.
func _get_se_index(se : StatusEffect) -> int:
	for i in range(active_status_effects.size()):
		if se.id == active_status_effects[i].id:
			return i
	return -1

## Sets the scale of this character.
func set_character_scale(size: float):
	var base_size := attributes.base_size
	var diff_ratio := size/(scale[0]*base_size)
	set_scale(Vector2(size/base_size,size/base_size))
	character_camera_ref.zoom *= Vector2(1.0, 1.0)/diff_ratio

## Sets visibility of the attribues panel
func _attune_self(se: StatusEffect, is_removing : bool = false) -> bool:
	var se_index : int = _get_se_index(se)
	
	if is_removing or se.value == 0.0:
		if se_index == -1:
			return false
		attribute_display_ref.visible = false
		update_status_bar(se, se_index, true)
		return true
	
	if se.value == 1.0: ## add = true
		if se_index == -1: ## If not already set:
			attribute_display_ref.visible = true ## Value should be either 1 = true or 0 = false.
			update_status_bar(se)
			return true
		if se.duration > active_status_effects[se_index].duration: ## Keep the longer duration
			update_status_bar(se, se_index)
		return true
	return false

### Collision Functions ###

## Checks the rigid body that is near the character to see if it is pushable.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pushable"):
		if attributes.get_attribute("strength") >= body.mass:
			pushing_bodies.append(body)
	if body.is_in_group("Crawlspace"):
		if attributes.get_attribute("size") <= body.gap_size:
			if crawlspace_bodies.is_empty():
				## Remove collision from crawlspaces nearby
				## NOTE: Assumes that all nearby crawlspaces have the same gap size.
				set_collision_mask_value(6, false)
			crawlspace_bodies.append(body)

## Checks if the body is in an existing list of overlapping bodies to remove it.
func _on_area_2d_body_exited(body: Node2D) -> void:
	var i := pushing_bodies.find(body)
	if i != -1:
		pushing_bodies.remove_at(i)
		return
	i = crawlspace_bodies.find(body)
	if i != -1:
		crawlspace_bodies.remove_at(i)
		if crawlspace_bodies.is_empty():
			set_collision_mask_value(6, true)

## Check the mass of the object and compare to the player's strength
## to determine if the player is strong enough to move the body.
func _push_body(body: PhysicsBody2D) -> bool:
	if attributes.get_attribute("strength") <= body.mass:
		return false
	## Calculate force based on the strength of the character vs the mass of the body.
	var mult : float
	## 50 is the extra strength needed over the mass to push at max velocity.
	mult = (attributes.get_attribute("strength") - body.mass) / 50
	if mult > 1:
		mult = 1
		
	body.linear_velocity = velocity * mult
	return true
