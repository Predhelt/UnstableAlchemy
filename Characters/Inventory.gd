## List of inventory items in the character's inventory.
class_name Inventory extends Resource

## Max number of slots in the inventory. Should not be changed as
## the inventory UI does not dynamically update its size based on this count.
@export var max_item_count := 24 
## List of items in the inventory
@export var items : Array[Item]

## Adds an item to the inventory.
func add_item(item : Item) -> bool:
	if item == null or item.qty <= 0: ## If invalid item or empty item
		return false
	
	var could_pickup : bool = add_stackable_item(item) ## Add to any existing stacks
	
	if item.qty <= 0: ## If item was added to existing stacks
		return true
	
	if items.size() < max_item_count:
		items.append(item)
		return true
	
	return could_pickup

## Adds item to a stack/slot or multiple stacks in inventory
func add_stackable_item(item : Item) -> bool:
	if item.max_qty < 2:
		return false # not stackable
	
	var could_pickup : bool = false
	
	for cur_item in items:
		if cur_item == null:
			print("Warning: Null item in Inventory")
			continue
		
		if cur_item.id != item.id or cur_item.qty >= cur_item.max_qty:
			continue ## If not a match or the item stack is full
		
		if cur_item.qty + item.qty > cur_item.max_qty: ## Only add until stack is full
			var amount_to_remove : int = cur_item.max_qty - cur_item.qty
			
			cur_item.qty = cur_item.max_qty
			item.qty -= amount_to_remove
			
			return true
		
		## If the stack is a match
		cur_item.qty += item.qty
		item.qty = 0
		return true
	
	if items.size() >= max_item_count:
		print("Inventory is full")
		return could_pickup
	
	items.append(item.duplicate())
	item.qty = 0
	return true

## Removes the list of inventory items from the inventory.
## If isRemoveingStacks is true, removes any stack that contains any item in the array of items.
func remove_items(items_removing : Array[Item], qtys : Array[int], isRemovingStacks : bool = false) -> bool: ## Returns false if not enough items are found for each item in the inventory
	## Phase 1: Check to see if there are enough of each item. If removing stacks, ignore phase 1
	var inventory_item_infos : Dictionary = {} ## Key : index, Value : id of items in inventory
	
	if not isRemovingStacks:
		
		inventory_item_infos = get_item_indices(items_removing, qtys)
	
		if inventory_item_infos == {}:
			return false
	
		## Phase 2: remove items from inventory
		var inventory_indices : Array = inventory_item_infos.keys()
		inventory_indices.sort()
		inventory_indices.reverse() ## Descending order because the size will change if an item is removed from the inventory item list
		
		for inventory_index in inventory_indices:
			for cur_item_index in range(items_removing.size()):
				var cur_item = items_removing[cur_item_index]
				## Find matching IDs
				if inventory_item_infos[inventory_index] == cur_item.id:
					var cur_qty = qtys[cur_item_index]
					if cur_qty < 0:
						print("error, trying to remove negative quantity of" + cur_item.display_name)
					if cur_qty == 0: ## Nothing to remove, skip to next index.
						break
					## Remove item qty from index in inventory
					var inventory_item = items[inventory_index]
					if cur_qty < inventory_item.qty:
						inventory_item.qty -= cur_qty ## Only remove some if amount is less than the stack
						qtys[cur_item_index] = 0
						break
					else:
						#remove_inventory_slot(inventory_index)
						items.remove_at(inventory_index)
						qtys[cur_item_index] -= inventory_item.qty
		
		## Confirm that all requested items have been removed from inventory
		var sum : int = 0
		for qty in qtys:
			sum += qty
		if sum > 0:
			return false
		else:
			return true
	
	##  If removing all instances of items:
	for i in range(items.size()-1,0): # Descending so that decreasing array size does not cause out of bound error
		if i >= items.size(): # Index can be greater than size if multiple items are removed from list
			continue
		for item_removing in items_removing:
			if items[i].id == item_removing.id:
				#remove_inventory_slot(i)
				items.remove_at(i)
	return true

## Returns whether the inventory contains any amount of the requested item.
func has_item(item : Item) -> bool:
	for i in items:
		if i.id == item.id:
			return true
	return false

## Returns whether the inventory contains any amount of the requested item with given ID.
func has_item_id(item_id : int) -> bool:
	for item in items:
		if item.id == item_id:
			return true
	return false

## Returns whether the inventory contains the appropriate amount of each item.
func has_item_amounts(items_checking : Array[Item], qtys : Array[int]) -> bool:
	if items_checking.size() != qtys.size():
		print("ERROR: Items and quantities arrays should have the name size")
		return false
	
	for i in range(items_checking.size()):
		var temp_qty : int = qtys[i]
		for j in range(items.size()):
			if items_checking[i].id == items[j].id:
				if temp_qty <= items[j].qty:
					temp_qty = 0
					break
				else:
					temp_qty -= items[j].qty
		if temp_qty > 0: ## If not enough of the item was found:
			return false
	return true

## Returns the index of the first intance of the item. Returns -1 if no item found.
func get_item_index(item_id : int) -> int:
	for i in range(items.size()):
		if items[i].id == item_id:
			return i
	return -1

## Checks if the inventory has all items and their appropriate amounts.
## Returns a dictionary of Keys: indices and Values: IDs of the items in inventory.
func get_item_indices(items_checking : Array[Item], qtys : Array[int]) -> Dictionary:
	if items_checking.size() != qtys.size():
		print("ERROR: Items and quantities arrays should have the name size")
		return {}
	
	var found_items : Dictionary ## Key : index, Value : id of items in inventory
	
	for i in range(items_checking.size()):
		var temp_qty : int = qtys[i]
		for j in range(items.size()-1, -1, -1): # Descending order, to remove the later elements first.
			if items_checking[i].id == items[j].id:
				found_items[j] = items_checking[i].id
				if temp_qty <= items[j].qty:
					temp_qty = 0
					break
				else:
					temp_qty -= items[j].qty
		if temp_qty > 0:
			return {}
	
	return found_items

## Gets the list of items at the current index in the list of items in the inventory.
func get_inventory_item(index : int) -> Item:
	if index < 0 or index >= items.size():
		return null
	
	return items[index]
