extends Panel

var npc_ref : NPC

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_window()

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		pass
		#open_window()

func close_window() -> void:
	if global.mode != &"menu" or global.mode == &"minigame":
		return
	
	visible = false
	remove_from_group("menu")
	print(get_tree().get_nodes_in_group("menu"))
	if get_tree().get_nodes_in_group("menu").is_empty():
		global.mode = &"default"

## Opens window using reference to the NPC that opened the window to get the proper Dialogue and shop information
func open_window(npc : NPC) -> void:
	#%WindowName.text = npc.npc_name
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		
		npc_ref = npc
		
		%ButtonBack.visible = false
		visible = true

## Set up the dialogue page
func set_dialogue(dialogue : Dialogue) -> void:
	#TODO
	_set_text(dialogue.text)
	_add_dialogue_choices(dialogue.choices)
	pass


## Sets the dialogue text
func _set_text(text : String) -> void:
	%DialogueLabel.text = text

## Adds items to DialogueOptions for the player to select as a response to what is said in the DialogueBox.
## Returns whether the options were successfully added or not
func _add_dialogue_choices(choices : Array[Choice]) -> bool:
	#TODO
	
	return false

## Opens the shop window and closes the current dialogue window.
## Uses transaction information from the NPC to set up the shop window.
func open_shop() -> void:
	pass


func _on_trade_button_pressed() -> void:
	pass # Replace with function body.
