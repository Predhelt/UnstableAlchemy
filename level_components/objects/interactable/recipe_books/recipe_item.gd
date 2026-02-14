extends Node2D

## Name of the object (also the folder name the object is contained in)
@export var display_name := ""
## Description of the object given to the character 
@export var description := ""
## The book's information, containing the recipes.
@export var book_info : Book
## The combinations that can be made with the object using the dropper tool
@export var combinations : Array[ObjectCombination]

## Temporary effect to show during interaction
@export var interact_effect : PackedScene = preload("res://art/effects/object_interacted_effect.tscn")
## Show the amount of items gained when added to inventory
@export var item_gained_effect : PackedScene = preload("res://art/effects/items_gained_effect_world.tscn")

var inspection_panel_scene = preload("res://level_components/ui/windows/inspection_panel/inspection_panel.tscn")


func _ready() -> void:
	$InteractArea.interact_label = display_name


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


func _on_object_cut(character: Character):
	pickup_book(character)

func _on_object_grabbed(character: Character):
	pickup_book(character)

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
	

func pickup_book(character : Character) -> void:
	if not character.inventory.add_item(book_info):
		print("Error, item not added to inventory")
		return
	
	var item_gained_effect_instance : Control = item_gained_effect.instantiate()
	item_gained_effect_instance.add_item(book_info, 1)
	item_gained_effect_instance.position = position
	get_parent().add_child(item_gained_effect_instance)
	
	## remove item from world
	self.queue_free()

func emit_effect():
	var effect_instance : GPUParticles2D = interact_effect.instantiate()
	effect_instance.position = position
	get_parent().add_child(effect_instance)
	effect_instance.emitting = true


func _on_object_combined(character: Character, item: Item) -> void:
	if not item:
		return
	for c in combinations:
		if c.input_item.id == item.id:
			character.update_status_message(c.status_message)
			mutate_object(c.result_object_scene)
			character._on_interaction_area_exited($InteractArea)
			emit_effect()
			character._on_interaction_area_entered($InteractArea)
			return
	character.update_status_message("...")

func mutate_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	obj._ready()
	
	#var obj_sprite = obj.find_child("Sprite2D")
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	display_name = obj.display_name
	description = obj.description
	book_info = obj.book_info
	#items = obj.items
	
	#item_quantities = []
	#for item in items:
		#item_quantities.append(item.qty)
	
	combinations = obj.combinations
	
	var obj_ia = obj.find_child("InteractArea")
	$InteractArea.interact_label = obj_ia.interact_label
	$InteractArea.interact_type = obj_ia.interact_type
	$InteractArea.interact_value = obj_ia.interact_value
	
