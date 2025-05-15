extends Node2D

@export var object_name := "" ## Name of the object
@export var object_description := "" ## Description of the object given to the player
@export var items : Array[Item] ## The items that the object contains and their initial quantities
var item_quantities : Array[int] ## The current quantities of items in the object

# TODO: Conditions for event triggers (e.g. receiveing certain Items) on action

@export var on_grab_items : Array[Item] ## The items to be received upon grabbing (taken out of "items").
@export var on_grab_amounts : Array[int] ## The amount of items to be recieved upon grabbing (taken out of "items).

@export var on_grab_effects : Array[StatusEffect]
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
	if on_grab_items.is_empty():
		print("No items to grab!")
		
	var grabbed_item_names := []
	var grabbed_item_counts := []
	
	for i in len(on_grab_items): # Grabbing each grabbable item
		var grab_item = on_grab_items[i]
		var id = grab_item.ID
		var grab_qty = on_grab_amounts[i]
		for j in len(items):
			if items[j].ID != id or item_quantities[j] <= 0:
				continue # If not the right item or item is empty
			
			var grabbed_item := items[j].duplicate()
			if item_quantities[j] <= grab_qty: # If the amount in object is <= the amount to grab
				grabbed_item.qty = item_quantities[j]
				item_quantities[j] = 0
			else:
				grabbed_item.qty = grab_qty
				item_quantities[j] -= grab_qty
			
			# Initialize the rest of the grabbed item to add to Inventory
			#grabbed_item.ID = id
			
			grabbed_item_names.append(grabbed_item.display_name)
			grabbed_item_counts.append(grab_qty)
			player.inventory.add_inventory_item(grabbed_item) # Returns boolean. May ffbe partially added if inventory becomes full
			
			if grabbed_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item_quantities[j] += grabbed_item.qty
	
	$InteractArea.close_context_menu()
	
	var sum = 0
	for item_qty in item_quantities:
		sum += item_qty
	if sum <= 0:
		#print("No items left in object")
		queue_free()
	
	# decrease count of item in object,
	
	
	# remove object from map if no items left in object
	
