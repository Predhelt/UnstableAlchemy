extends Node2D

## Name of the object (also the folder name the object is contained in)
@export var display_name := ""
## Description of the object given to the player 
@export var description := ""
## The recipe(s) that the item contains
@export var recipes : Array[Recipe]
## The combinations that can be made with the object using the dropper tool
@export var combinations : Array[ObjectCombination]

## Temporary effect to show during interaction
@export var interact_effect : PackedScene = preload("res://Effects/object_interacted_effect.tscn")
## Show the amount of items gained when added to inventory
@export var item_gained_effect : PackedScene = preload("res://Effects/items_gained_effect_world.tscn")

var inspection_panel_scene = preload("res://UI/Interactable Object/inspection_panel.tscn")


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


func _on_object_inspected() -> void:
	inspect_object()
	
func inspect_object():
	
	var inspection_panel = find_child("InspectionPanel")
	if global.mode == &"inspection":
		return
	inspection_panel = inspection_panel_scene.instantiate()
	inspection_panel.name = "InspectionPanel"
	inspection_panel.object_name = display_name
	inspection_panel.object_description = description
	inspection_panel.object_image = $Sprite2D.texture
	inspection_panel.add_to_group("open_window")
	add_child(inspection_panel)
	global.mode = &"inspection"
	

func _on_recipe_read(player: Player) -> void:
	var item_gained_effect_instance : Control = item_gained_effect.instantiate()
	
	# TODO:
	# Add recipe to recipe list (if not already in recipe)
	# remove item from world
	# if new recipe, show effect. If not, say already learned
	
	
	
	get_parent().add_child(item_gained_effect_instance)

func emit_effect():
	var effect_instance : GPUParticles2D = interact_effect.instantiate()
	effect_instance.position = position
	get_parent().add_child(effect_instance)
	effect_instance.emitting = true


func _on_object_combined(player: Player, item: Item) -> void:
	if not item:
		return
	for c in combinations:
		if c.input_item.id == item.id:
			player.update_status_message(c.status_message)
			mutate_object(c.result_object_scene)
			player._on_interaction_area_exited($InteractArea)
			emit_effect()
			player._on_interaction_area_entered($InteractArea)
			return
	player.update_status_message("...")

func mutate_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	obj._ready()
	
	#var obj_sprite = obj.find_child("Sprite2D")
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	display_name = obj.display_name
	description = obj.description
	recipes = obj.recipes
	#items = obj.items
	
	#item_quantities = []
	#for item in items:
		#item_quantities.append(item.qty)
	
	combinations = obj.combinations
	
	var obj_ia = obj.find_child("InteractArea")
	$InteractArea.interact_label = obj_ia.interact_label
	$InteractArea.interact_type = obj_ia.interact_type
	$InteractArea.interact_value = obj_ia.interact_value
	
