extends Node2D

@export var object_name := "Green Herb"
@export var object_description := "A green herb with medicinal properties. Looks pretty normal."
@export var inventory : Inventory
@export var items : Array[Item]
@export var on_grab_items := {} # Key: Item, Value: Amount
# TODO: Conditions for event triggers (e.g. receiveing certain Items) on action
@export var on_grab_effects : Array[StatusEffect]
var context_menu
var inspection_panel_scene = preload("res://UI/ContextMenu/inspection_panel.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_object_inspected() -> void:
	var inspection_panel = find_child("InspectionPanel")
	if not inspection_panel:
		inspection_panel = inspection_panel_scene.instantiate()
	inspection_panel.object_name = object_name
	inspection_panel.object_description = object_description
	inspection_panel.object_image = $Sprite2D.texture
	add_child(inspection_panel)
	


func _on_object_grabbed() -> void: 
	if on_grab_items.is_empty():
		print("No items to grab!")
		
	var grabbed_item_names := []
	var grabbed_item_counts := []
	
	for grab_item in on_grab_items.keys(): # Grabbing each grabbable item
		var id = grab_item.ID
		var cur_qty = on_grab_items[grab_item]
		for i in len(items):
			var item = items[i]
			if item.ID != id or item.qty <= 0:
				continue # If not the right item or item is empty
			
			var grabbed_item := item.duplicate()
			if item.qty <= cur_qty: # If the amount in object is <= the amount to grab
				grabbed_item.qty = item.qty
				items.remove_at(i)
			else:
				grabbed_item.qty = cur_qty
				item.qty -= cur_qty
			
			# Initialize the rest of the grabbed item to add to Inventory
			#grabbed_item.ID = id
			
			grabbed_item_names.append(grabbed_item.display_name)
			grabbed_item_counts.append(cur_qty)
			inventory.add_inventory_item(grabbed_item) # Returns boolean. May be partially added if inventory becomes full
			
			if grabbed_item.qty > 0: # return any items that couldn't fit in inventory back to the object
				item.qty += grabbed_item.qty
	
	$InteractArea.close_context_menu()
	
	for i in len(grabbed_item_names):
		print("you got " + str(grabbed_item_counts[i]) + " " + grabbed_item_names[i])
	
	if not items:
		print("No items left in object")
		queue_free()
	
	# decrease count of item in object,
	
	
	# remove object from map if no items left in object
	
