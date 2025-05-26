extends Node2D

@export var object_name := "" ## Name of the object
@export var object_description := "" ## Description of the object given to the player
@export var items : Array[Item] ## The items that the object contains and their initial quantities
var item_quantities : Array[int] ## The current quantities of items in the object

@export var interact_effect : PackedScene = preload("res://Effects/object_interacted_effect.tscn") ## Temporary effect to show during interaction
@export var item_gained_effect : PackedScene = preload("res://Effects/items_gained_effect.tscn") ## Show the amount of items gained when added to inventory

@export var grab_interaction : InteractionType
@export var cut_interaction : InteractionType
@export var combinations : Array[ObjectCombination]

var context_menu : Control
var inspection_panel_scene = preload("res://UI/ContextMenu/inspection_panel.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in items:
		item_quantities.append(item.qty)

func _on_object_inspected() -> void:
	inspect_object()
	
func inspect_object():
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
		player.update_status_effects(grab_interaction.on_interact_status_effects, grab_interaction.on_interact_status_message)
	
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
		return
		
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
			
			
			if player.inventory_ref.add_inventory_item(interaction_item): # Returns boolean. May be partially added if inventory becomes full
				item_gained_effect_instance.add_item(interaction_item, interact_qty - interaction_item.qty)
			
			if interaction_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item_quantities[j] += interaction_item.qty
	
	item_gained_effect_instance.position = position
	get_parent().add_child(item_gained_effect_instance)
	
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


func _on_object_combined(player: Player, item: Item) -> void:
	for c in combinations:
		if c.input_item.id == item.id:
			player.update_status_message(c.status_message)
			mutate_object(c.result_object_scene)
			player._on_interaction_area_exited($InteractArea)
			emit_effect()
			player._on_interaction_area_entered($InteractArea)

func mutate_object(new_object_scene: PackedScene):
	var obj = new_object_scene.instantiate()
	
	#var obj_sprite = obj.find_child("Sprite2D")
	$Sprite2D.texture = obj.find_child("Sprite2D").texture
	
	object_name = obj.object_name
	object_description = obj.object_description
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
	
	
