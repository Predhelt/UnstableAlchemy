extends AlchemyTool

func _init() -> void:
	window_mode = &"menu"
	buttons.append(null)
	items.append(null)

func _ready() -> void:
	if items.size() >= 0 and items.size() < 2:
		button_confirm.disabled = false
	else:
		button_confirm.disabled = true
	buttons = [$ToolIcon/ItemGrid/Button1]
	set_recipes(&"Mortar & Pestle")

## Find first item in queue to start using in the mortar and pestle,
## Then open the M&P minigame page using the relevant item.
func _use_items(): # Overrides the _use_items() function in AlchemyTool
	#if items[0]:
	open_minigame([items[0]]) # Does not remove craft item for testing

## Adds an item to the mortar & pestle in the inventory.
## Overrides parent function.
func add_item(item: Item) -> bool:
	if is_using:
		print("WARNING: Please wait for " + tool_name + " to finish")
		return false
	if num_items >= 1:
		#print(tool_name + " already full!")
		inventory_menu_ref.add_inventory_item(item)
		return false

	if not items[0]:
		items[0] = item
		buttons[0].texture_normal = item.texture
		buttons[0].disabled = false
		button_confirm.disabled = false
		num_items += 1
		return true
	
	print("Error: should never happen. if full of items, should have returned earlier")
	return false
