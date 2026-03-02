extends Node2D

## Reference to the main camera used for displaying to the user.
var focused_camera : Camera2D
## Reference to the node that has focus of the window's camera.
var focused_node : Node
## File path of the current level
var current_level_path : String
## Tracks if an item is being dragged by the mouse / cursor.
var is_dragging := false
## Keeps reference of the blank texture that is used when another texture is not available.
var blank_texture := preload("res://art/pack/ui/blank_item.png")
## Keeps track of the state that the game is in to determine what types of actions are allowed.
## Modes are: "default", "menu", "minigame", "dropper", "inspection"(unused), "settings", "options"
var mode := &"default"
## Tracks the current absolute size and mass of the player.
var player_scale := Vector2(1.0, 1.0)

## Keeps track of the window on the left side of the screen
var left_window : Control
## Keeps track of the window on the right side of the screen
var right_window : Control
## Keeps track of the window in the center of the screen
var center_window : Control


## Checks input action events and closes a window.
## Closes the center window, or right, or left, respectively.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if center_window:
			center_window.close_window()
		elif right_window:
			right_window.close_window()
		elif left_window:
			left_window.close_window()

## Changes the root node of the scene. Used for changing levels.
func change_scene(scene_path : String):
	if scene_path == null:
		return
	_deferred_change_scene.call_deferred(scene_path)
	mode = &"default"
	current_level_path = scene_path

## Defer to pevent errors when signal is called during physics process.
func _deferred_change_scene(path : String):
	get_tree().change_scene_to_file(path)

## Save the persistent game informaion to file. Uses dict to store data as JSON.
func save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	# Store global data at top of the file.
	var node_data : Dictionary = save()
	var json_string : String = JSON.stringify(node_data)
	save_file.store_line(json_string)
	
	# Store the user data next.
	node_data = UserVariables.call("save")
	json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
	
	# TODO: Remove current (outdated) directories in save location
	DirAccess.remove_absolute("user://save") #FIXME: Does not work if directory is not empty.
	
	# Store persistent node data.
	var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		# Call the node's save function.
		node_data = node.call("save")
		
		# JSON provides a static method to serialized JSON string.
		json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

## Save the persistent Global variables as a dictionary.
func save() -> Dictionary:
	return {
		"focused_camera" : focused_camera,
		"focused_node" : focused_node,
		"current_level_path" : current_level_path,
	}

## Loads the game state based on the savegame.save file in the user directory.
func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		print("ERROR: No save file found!")
		return
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	# Initialize variables and change the level scene.
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	var node_data = json.data
	if node_data["current_level_path"]:
		var level_node : Node2D = load(node_data["current_level_path"]).instantiate()
		get_tree().change_scene_to_node(level_node)
		# Wait for the scene to load before continuing.
		await level_node.ready
	else:
		print("ERROR: No level data found. Returning.")
		return
	
	# Set User Variables
	json_string = save_file.get_line()
	json = JSON.new()
	parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	for i in node_data.keys():
		UserVariables.set(i, node_data[i])
	
	# Free the nodes in the persistent group to revert game state without cloning.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	# Wait for the nodes to be freed from the level.
	await get_tree().get_nodes_in_group("Persist")[-1].tree_exited
	
	# Set node data
	while save_file.get_position() < save_file.get_length():
		json_string = save_file.get_line()
	
		json = JSON.new()
		parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		node_data = json.data
		var new_object : Node2D = load(node_data["filename"]).instantiate()
		new_object.name = node_data["name"]
		
		# Add status effects before connecting to parent, if status effects exist.
		var field : String = "active_status_effects_path"
		if node_data[field]:
			if DirAccess.dir_exists_absolute(node_data[field]):
				var se_dir : DirAccess = DirAccess.open(node_data[field])
				if se_dir != null:
					# Get each status effect resource from file and add it to object.
					var se_list : PackedStringArray = se_dir.get_files()
					for se_name in se_list:
						var cur_se : StatusEffect = load(node_data[field] + se_name)
						#new_object.apply_status_effect(cur_se)
						new_object.active_status_effects.append(cur_se)
		
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		# Go through each node and initialize the stored values..
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "active_status_effects_path":
				continue
			if i == "is_camera_focused" and node_data[i] == true:
				focused_node = new_object
				var cam : Camera2D = get_tree().root.get_children()[-1].find_child("PlayerCamera")
				#cam.position.x = node_data["pos_x"]
				#cam.position.y = node_data["pos_y"]
				
				focused_camera = cam
				new_object.character_camera_ref = cam
				new_object.set_camera()
				cam.reset_smoothing()
				continue
			if i == "inventory_path":
				new_object.inventory = ResourceLoader.load(node_data[i], "", ResourceLoader.CACHE_MODE_REPLACE)
				#TODO: Check if replacing cached version is making a difference.
				#FIXME: Replace the existing inventory instead of loading a new instance.
				continue
			if i == "attributes_path":
				new_object.attributes = ResourceLoader.load(node_data[i], "", ResourceLoader.CACHE_MODE_REPLACE)
				continue
			
			new_object.set(i, node_data[i])
	mode = &"default"

#TODO: add items and recipes based on the spreadsheet
#TODO: Remake UI with mobile-first
