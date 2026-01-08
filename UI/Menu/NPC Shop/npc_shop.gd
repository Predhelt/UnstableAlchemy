extends Panel

#@export var known_recipes : Array[Recipe]

@export var transactions : Array[Transaction]


func _ready() -> void:
	
	%WindowName.text = "Shop"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode != &"menu" or global.mode == &"minigame":
		return
	
	visible = false
	remove_from_group("menu")
	print(get_tree().get_nodes_in_group("menu"))
	if get_tree().get_nodes_in_group("menu").is_empty():
		global.mode = &"default"
	


func open_window() -> void:
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		
		for transaction in transactions:
			pass #TODO: convert exported transactions into display items
			#var display_text := ""
			#
			#display_text += transaction.display_name
			#%ShopItems.add_transaction(display_text, transaction.texture)
		%ShopItems.visible = true
	
		%ButtonBack.visible = false
		visible = true


func _on_button_close_pressed() -> void:
	close_window()


func _on_button_back_pressed() -> void:
	close_window()
	open_window()
