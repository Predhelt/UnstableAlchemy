extends Node2D

@export var object_name := "" ## Name of the object
@export var object_description := "" ## Description of the object given to the player
@export var items : Array[Item] ## The items that the object contains and their initial quantities
var item_quantities : Array[int] ## The current quantities of items in the object


@export var grab_interaction : InteractionType
@export var cut_interaction : InteractionType
@export var combinations : ObjectCombinations

var context_menu : Control
var inspection_panel_scene = preload("res://UI/ContextMenu/inspection_panel.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in items:
		item_quantities.append(item.qty)

func _on_object_inspected() -> void:
	var inspection_panel = find_child("InspectionPanel")
	if not inspection_panel:
		inspection_panel = inspection_panel_scene.instantiate()
	inspection_panel.object_name = object_name
	inspection_panel.object_description = object_description
	inspection_panel.object_image = $Sprite2D.texture
	add_child(inspection_panel)
	

func _on_object_grabbed(player: Player) -> void:
	collect_items(player, grab_interaction)
	
	if grab_interaction.on_interact_status_effects:
		player.update_status_effects(cut_interaction.on_interact_status_effects, cut_interaction.on_interact_status_message)
	
func _on_object_cut(player: Player) -> void:
	collect_items(player, cut_interaction)
	if cut_interaction.on_interact_status_effects:
		player.update_status_effects(cut_interaction.on_interact_status_effects, cut_interaction.on_interact_status_message)
	
func collect_items(player: Player, interaction: InteractionType) -> void:
	if not interaction:
		print("No interaction")
		return
	
	if interaction.on_interact_items.is_empty():
		print("No items to get!")
		
	var interaction_item_names := []
	var interaction_item_counts := []
	
	for i in len(interaction.on_interact_items): # Getting each interactable item
		var interact_item = interaction.on_interact_items[i]
		var id = interact_item.ID
		var interact_qty = interaction.on_interact_amounts[i]
		for j in len(items):
			if items[j].ID != id or item_quantities[j] <= 0:
				continue # If not the right item or item is empty
			
			var interaction_item := items[j].duplicate()
			if item_quantities[j] <= interact_qty: # If the amount in object is <= the amount to interact
				interaction_item.qty = item_quantities[j]
				item_quantities[j] = 0
			else:
				interaction_item.qty = interact_qty
				item_quantities[j] -= interact_qty
			
			
			interaction_item_names.append(interaction_item.display_name)
			interaction_item_counts.append(interact_qty)
			player.inventory_ref.add_inventory_item(interaction_item) # Returns boolean. May ffbe partially added if inventory becomes full
			
			if interaction_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item_quantities[j] += interaction_item.qty
	
	var sum = 0
	for item_qty in item_quantities:
		sum += item_qty
	if sum <= 0:
		#print("No items left in object")
		queue_free()


func _on_object_combined(player: Player, item: Item) -> void:
	if not combinations:
		return
	for i in len(combinations.item_ids):
		if combinations.item_ids[i] == item.ID:
			player.update_status_message(combinations.combination_messages[i])
			_mutate_object(combinations.result_object_scenes[i])
			player._on_interaction_area_exited($InteractArea)
			player._on_interaction_area_entered($InteractArea)

func _mutate_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	object_name = obj.object_name
	object_description = obj.object_description
	items = obj.items
	item_quantities = obj.item_quantities
	grab_interaction = obj.grab_interaction
	cut_interaction = obj.cut_interaction
	combinations = obj.combinations
	
	var obj_ia = obj.find_child("InteractArea")
	$InteractArea.interact_label = obj_ia.interact_label
	$InteractArea.interact_type = obj_ia.interact_type
	$InteractArea.interact_value = obj_ia.interact_value
	
	
