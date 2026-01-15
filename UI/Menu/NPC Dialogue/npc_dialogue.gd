extends Panel

var npc_ref : NPC
var cur_dialogue : Dialogue

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
	if not npc:
		print("Error, no npc found.")
		return
	
	npc_ref = npc
	%WindowName.text = npc_ref.npc_name
	if global.mode == &"default" or global.mode == &"menu" or global.mode == &"minigame":
		global.mode = &"menu" # Shares mode with inventory, minigame, and help menu
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		
		set_dialogue(npc_ref.dialogue_tree.default_dialogue)
		
		
		%ButtonBack.visible = false
		visible = true

## Set up the dialogue page
func set_dialogue(dialogue : Dialogue) -> void:
	cur_dialogue = dialogue
	_set_text(dialogue.text)
	_add_dialogue_choices(dialogue.choices)


## Sets the dialogue text
func _set_text(text : String) -> void:
	%DialogueLabel.text = text

## Adds items to DialogueOptions for the player to select as a response to what is said in the DialogueBox.
## Returns whether the options were successfully added or not
func _add_dialogue_choices(choices : Array[Choice]) -> void:
	%DialogueOptions.clear()
	for choice in choices:
		%DialogueOptions.add_item(choice.player_response)

## Finds the dialogue in the tree given the name of the dialogue
func find_dialogue(dialogue_name : String) -> Dialogue:
	for dialogue : Dialogue in npc_ref.dialogue_tree.dialogues:
		if dialogue.dialogue_name == dialogue_name:
			return dialogue
	return null

## Opens the next page of dialogue based on the choice made by the player.
func next_dialogue(choice : Choice) -> void:
	set_dialogue(find_dialogue(choice.next_dialogue_name))

## set the value for the default dialogue page in the default dialogue tree.
func set_default_dialogue(dialogue_name : String) -> void:
	var dialogue : Dialogue = find_dialogue(dialogue_name)
	if not dialogue:
		print("ERROR: No dialogue with name "+dialogue_name+" found")
		return
	npc_ref.dialogue_tree.default_dialogue = dialogue

## Executes the each Happening, which 
func execute_happenings(h_paths : Array[String]) -> bool:
	for h_path : String in h_paths: # For each file path,
		var h_script : Node = load(h_path).new() # generate the script
		if not h_script:
			print("Error: "+h_path+"Not a valid file path")
			return false
		h_script.set_npc_dialogue_ref(self) # Set the context for the script
		h_script.execute_functions() # Execute any functions associated with the script
		h_script.queue_free()
	return true

## Opens the shop window and closes the current dialogue window.
## Uses transaction information from the NPC to set up the shop window.
func open_shop() -> void:
	close_window()
	npc_ref.open_shop()


func _on_dialogue_options_item_selected(index: int) -> void:
	var choice : Choice = cur_dialogue.choices[index]
	execute_happenings(choice.happenings)
	
	next_dialogue(choice)

func _on_trade_button_pressed() -> void:
	open_shop()
