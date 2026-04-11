## An object that can be interacted with by the player.
## May contain items and different types of interactions with the object produce different results.
class_name InteractableObject extends Node2D

## Name of the object (also the folder name the object is contained in).
@export var display_name := ""
## Description of the object given to the character .
@export var description := ""
## The items that the object contains and their initial quantities.
@export var items : Array[Item]
## The current quantities of items in the object since item.qty is referenced and not local.
var item_quantities : Array[int]
## The Interaction that is used when the object is grabbed.
## Can be left blank if this is handled 
@export var grab_interaction : Interaction
## The Interaction that is used when the object is cut.
@export var cut_interaction : Interaction
## The list of possible combinations that this object can have with items.
@export var combinations : Array[ObjectCombination]

var context_menu : Control
var inspection_panel_scene : PackedScene = preload("res://level_components/ui/windows/inspection_panel/inspection_panel.tscn")

## Temporary effect to show during interaction.
@export var interact_effect : PackedScene = preload("res://art/effects/object_interacted_effect.tscn")
## Show the amount of items gained when added to inventory in the world.
@export var items_gained_effect : PackedScene = preload("res://art/effects/items_gained_effect_world.tscn")

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in items:
		item_quantities.append(item.qty)

## Get the local file path of the current object.
func get_cur_folder_path() -> String:
	var folder_path := ""
	var path := scene_file_path.split("/")
	var path_counter := 1
	for dir_name in path:
		if path_counter >= len(path):
			break
		
		folder_path += dir_name + "/"
		path_counter += 1
	return folder_path

## Check if the object has no items left. If so, free the object from memory.
func check_empty():
	var sum = 0
	for item_qty in item_quantities:
		sum += item_qty
	if sum <= 0:
		#print("No items left in object")
		emit_effect()
		queue_free()

## Emits a particle effect on top of the object determined by interact_effect.
func emit_effect():
	var effect_instance : GPUParticles2D = interact_effect.instantiate()
	effect_instance.position = position
	get_parent().add_child(effect_instance)
	effect_instance.emitting = true

## Removes items from the object. Adds any items to the character's inventory
## based on the interaction. Displays on screen the items that were collected.
func collect_items(character: Character, interaction: Interaction) -> bool:
	if not interaction:
		print("No interaction")
		return false
	
	if interaction.on_interact_items.is_empty():
		print("No items to get!")
		return false
		
	var items_gained_effect_instance : Control = items_gained_effect.instantiate()
	var is_item_collected : bool = false
	
	for i in len(interaction.on_interact_items): # Getting each interactable item
		var interact_item : Item = interaction.on_interact_items[i]
		var id : int = interact_item.id
		var interact_qty : int = interaction.on_interact_amounts[i]
		for j in len(items):
			if items[j].id != id or item_quantities[j] <= 0:
				continue # If not the right item or item is empty
			
			var interaction_item := items[j].duplicate()
			if item_quantities[j] < interact_qty: # The amount to collect is greater than the amount in object
				interaction_item.qty = item_quantities[j]
				interact_qty = item_quantities[j]
				item_quantities[j] = 0
			else:
				interaction_item.qty = interact_qty
				item_quantities[j] -= interact_qty
			
			if character.inventory.add_item(interaction_item): # Returns boolean. May be partially added if inventory becomes full
				items_gained_effect_instance.add_item(interaction_item, interact_qty - interaction_item.qty)
			
			if interaction_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item_quantities[j] += interaction_item.qty
			
			is_item_collected = true
	
	if not is_item_collected:
		items_gained_effect_instance.set_no_items_gained()
	
	items_gained_effect_instance.position = position
	get_parent().add_child(items_gained_effect_instance)
	
	return true

## Adds the interaction record to the node's given interaction dictionary, if not already.
func _add_interaction_to_node(dict : Dictionary, interaction : Interaction) -> void:
	if dict.keys().is_empty() or display_name not in dict.keys():
		dict[display_name] = [interaction, 1]
	#elif interaction not in dict[display_name].keys():
		#dict[display_name][1] = 1
	else:
		dict[display_name][1] += 1

## Add the interaction with the given type to the node's gathered_items.
func _add_gathered_items_entry_to_node(node : Node, interaction : Interaction, type : String) -> void:
	for item in interaction.on_interact_items:
		var entry = [display_name, type]
		if node.gathered_items.keys().is_empty() or item.id not in node.gathered_items.keys():
			node.gathered_items[item.id] = {entry : 1}
			if item.type == "Book":
				continue
			if "is_camera_focused" not in node: # Implied that UserVariables is being updated if is_camera_focused is not a variable in the node.
				Global.emit_notification("Log Book Entry Added")
		elif entry not in node.gathered_items[item.id].keys():
			node.gathered_items[item.id][entry] = 1
		else:
			node.gathered_items[item.id][entry] += 1


func _on_object_grabbed(character: Character) -> void:
	if not collect_items(character, grab_interaction):
		return
	
	_add_interaction_to_node(character.objects_grab_interacted, grab_interaction)
	_add_gathered_items_entry_to_node(character, grab_interaction, "grab")
	if character.is_camera_focused:
		_add_interaction_to_node(UserVariables.objects_grab_interacted, grab_interaction)
		_add_gathered_items_entry_to_node(UserVariables, grab_interaction, "grab")
	
	if grab_interaction.on_interact_status_effects:
		character.update_status_effects(grab_interaction.on_interact_status_effects, grab_interaction.on_interact_status_message)
	
	check_empty()


func _on_object_cut(character: Character) -> void:
	if not collect_items(character, cut_interaction):
		return
	
	_add_interaction_to_node(character.objects_cut_interacted, cut_interaction)
	_add_gathered_items_entry_to_node(character, cut_interaction, "cut")
	if character.is_camera_focused:
		_add_interaction_to_node(UserVariables.objects_cut_interacted, cut_interaction)
		_add_gathered_items_entry_to_node(UserVariables, cut_interaction, "cut")
	
	if cut_interaction.on_interact_status_effects:
		character.update_status_effects(cut_interaction.on_interact_status_effects, cut_interaction.on_interact_status_message)
	
	check_empty()


func _on_object_inspected() -> void:
	inspect_object()

## Opens inspection panel for the object.
func inspect_object():
	#if Global.mode == &"inspection":
		#return
	var inspection_panel = find_child("InspectionPanel")
	inspection_panel = inspection_panel_scene.instantiate()
	inspection_panel.name = "InspectionPanel"
	inspection_panel.object_name = display_name
	inspection_panel.object_description = description
	inspection_panel.object_image = $Sprite2D.texture
	inspection_panel.add_to_group("open_window")
	add_child(inspection_panel)
	Global.mode = &"inspection"


func _on_object_combined(character: Character, item: Item) -> void:
	if not item:
		return
	for c in combinations:
		if c.input_item.id == item.id:
			_add_combination_to_node(character, c)
			if character.is_camera_focused:
				_add_combination_to_node(UserVariables, c)
			
			character.update_status_message(c.status_message)
			transform_object(c.result_object_scene)
			character._on_interaction_area_exited($InteractArea)
			emit_effect()
			character._on_interaction_area_entered($InteractArea)
			return
	
	character.update_status_message("...")

## Adds the [ObjectCombination] record to the node, if not already.
func _add_combination_to_node(node: Node, combination: ObjectCombination):
	for object_name in node.objects_combined.keys():
		if object_name == display_name:
			var combos = node.objects_combined[display_name]
			if not combination in combos: #TODO: Test if the combination reference works for matching.
				combos.append([combination, 0])
			else:
				# TODO: This is where the count would get added
				combos[1] += 1
			return
	## If no combinations for current object stored, set combination.
	node.objects_combined[display_name] = [combination, 0]

## Changes the current object to the new object based on the combination that occurred.
func transform_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	obj._ready()
	
	#var obj_sprite = obj.find_child("Sprite2D")
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	display_name = obj.display_name
	description = obj.description
	items = obj.items #NOTE: Any discrepency in item counts is not accounted for. New object always has default item counts.
	
	item_quantities = []
	for item in items:
		item_quantities.append(item.qty)
	
	grab_interaction = obj.grab_interaction
	cut_interaction = obj.cut_interaction
	combinations = obj.combinations
	
	var obj_ia = obj.find_child("InteractArea")
	$InteractArea.interact_label = obj_ia.interact_label
	$InteractArea.interact_type = obj_ia.interact_type
	$InteractArea.interact_value = obj_ia.interact_value
