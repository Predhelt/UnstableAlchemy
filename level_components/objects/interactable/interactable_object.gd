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
@export var item_gained_effect : PackedScene = preload("res://art/effects/items_gained_effect_world.tscn")

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#init_resources()
	
	for item in items:
		item_quantities.append(item.qty)


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


func check_empty():
	var sum = 0
	for item_qty in item_quantities:
		sum += item_qty
	if sum <= 0:
		#print("No items left in object")
		emit_effect()
		queue_free()


func emit_effect():
	var effect_instance : GPUParticles2D = interact_effect.instantiate()
	effect_instance.position = position
	get_parent().add_child(effect_instance)
	effect_instance.emitting = true


func collect_items(character: Character, interaction: Interaction) -> bool:
	if not interaction:
		print("No interaction")
		return false
	
	if interaction.on_interact_items.is_empty():
		print("No items to get!")
		return false
		
	var item_gained_effect_instance : Control = item_gained_effect.instantiate()
	
	for i in len(interaction.on_interact_items): # Getting each interactable item
		var interact_item = interaction.on_interact_items[i]
		var id = interact_item.id
		var interact_qty = interaction.on_interact_amounts[i]
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
				#TODO: Add information to character about which item was added and from which object.
				item_gained_effect_instance.add_item(interaction_item, interact_qty - interaction_item.qty)
			
			if interaction_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item_quantities[j] += interaction_item.qty
	
	item_gained_effect_instance.position = position
	get_parent().add_child(item_gained_effect_instance)
	
	return true


func _on_object_grabbed(character: Character) -> void:
	if not collect_items(character, grab_interaction):
		return
	
	if grab_interaction.on_interact_status_effects:
		character.update_status_effects(grab_interaction.on_interact_status_effects, grab_interaction.on_interact_status_message)
	
	check_empty()
	
func _on_object_cut(character: Character) -> void:
	if not collect_items(character, cut_interaction):
		return
	
	if cut_interaction.on_interact_status_effects:
		character.update_status_effects(cut_interaction.on_interact_status_effects, cut_interaction.on_interact_status_message)
	
	check_empty()

func _on_object_inspected() -> void:
	inspect_object()

#FIXME: Inspect not getting called properly.
func inspect_object():
	
	var inspection_panel = find_child("InspectionPanel")
	if Global.mode == &"inspection":
		return
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
			character.update_status_message(c.status_message)
			transform_object(c.result_object_scene)
			character._on_interaction_area_exited($InteractArea)
			emit_effect()
			character._on_interaction_area_entered($InteractArea)
			return
	character.update_status_message("...")


func transform_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	obj._ready()
	
	#var obj_sprite = obj.find_child("Sprite2D")
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	display_name = obj.display_name
	description = obj.description
	items = obj.items
	
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
