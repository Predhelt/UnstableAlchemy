extends Node2D

## Reference to the main camera used for displaying to the user.
var focused_camera : Camera2D
## Reference to the node that has focus of the window's camera.
var focused_node : Node
## File path of the current level
var current_level : String
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
	current_level = scene_path

## Defer to pevent errors when signal is called during physics process.
func _deferred_change_scene(path : String):
	get_tree().change_scene_to_file(path)

## Save the persistent game informaion to file. Uses dict to store data as JSON.
func save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	# Store the current level
	save_file.store_line(JSON.stringify({"current_level" : current_level}))
	
	var node_data
	var json_string
	
	# TODO: Store user data at top of the file.
	#node_data = UserVariables.call("save")
	#json_string = JSON.stringify(node_data)
	#save_file.store_line(json_string)
	
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

func save() -> Dictionary:
	return {} #TODO: Save global variables to file.


func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		print("ERROR: No save file found!")
		return
	
	### Free the nodes in the persistent group to revert game state without cloning.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	## Extract the level file
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	var node_data = json.data
	if node_data.keys()[0] == "current_level":
		pass
		#_deferred_change_scene(node_data["current_level"])
	else:
		print("ERROR: No level data found. Returning.")
		return
	
	while save_file.get_position() < save_file.get_length():
		json_string = save_file.get_line()
	
		json = JSON.new()
		parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		node_data = json.data
		var new_object : Node2D = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		var has_camera : bool = false
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			if i == "is_camera_focused" and node_data[i] == true:
				focused_node = new_object
				var cam  = get_tree().root.get_children()[-1].find_child("PlayerCamera")
				focused_camera = cam
				new_object.character_camera_ref = cam
				has_camera = true
				continue
			if i == "inventory": #TODO: Figure out save/load of resources
				new_object.inventory = node_data[i]
				continue
			if i == "attributes": #TODO: Figure out save/load of resources
				new_object.attributes = node_data[i]
			new_object.set(i, node_data[i])
		if has_camera:
			new_object.set_camera()
	
	

#TODO: add items and recipes based on the spreadsheet
#TODO: Remake UI with mobile-first
