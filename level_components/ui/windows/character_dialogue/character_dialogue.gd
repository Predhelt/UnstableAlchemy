extends UIWindow

## Reference to the character that is determining the dialogue and interactions
var character_ref : Character
## Reference to the player that is talking to the character
#var player_ref : Character
## The currend dialogue that is being used
var cur_dialogue : Dialogue

## Configures when relevant hotkeys are pressed
#func _input(event: InputEvent) -> void:
	#TODO: Use hotkeys to select dialogue choices or open shop

func _init() -> void:
	window_mode = &"menu"

## Removes the dialogue window from the menu category and hides the window.
func close_window() -> void:
	if Global.mode != window_mode:
		return
	
	visible = false
	Global.right_window = null
	if not Global.left_window and not Global.center_window:
		Global.mode = &"default"

## Opens window using reference to the character that opened the window.
## and the player that is talking to the Character
## to get the proper Dialogue and shop information.
func open_window_as_character(character : Character) -> bool:
	if not character:
		print("ERROR: no character found.")
		return false
	if Global.right_window or Global.center_window or visible:
		return false
	if Global.mode == &"default":
		Global.mode = window_mode
	if Global.mode == window_mode:
		Global.right_window = self
		character_ref = character
		#Global.focused_node = player
		%WindowName.text = character_ref.character_name
		set_dialogue(character_ref.get_initial_dialogue_name(Global.focused_node))
		
		%ButtonBack.visible = false
		visible = true
		return true
	return false


## Opens the window, assumes that the relevant character and player were already set
## and the page was previously loaded.
func open_window() -> bool:
	if Global.right_window or Global.center_window or visible:
		return false
	if Global.mode == &"default":
		Global.mode = window_mode
	if Global.mode == window_mode:
		Global.right_window = self
		
		%ButtonBack.visible = false
		visible = true
		return true
	return false

## Set up the dialogue page
func set_dialogue(dialogue_name : String) -> void:
	#FIXME: Need to replicate a bug that prevented current dialogue from being properly set
	cur_dialogue = find_dialogue(dialogue_name)
	if not cur_dialogue:
		print("ERROR: No matching dialogue \""+dialogue_name+"\" found in dialogue tree")
		return
	
	_set_text(cur_dialogue.text)
	_add_dialogue_choices(cur_dialogue.choices)

## Finds the dialogue in the tree given the name of the dialogue
func find_dialogue(dialogue_name : String) -> Dialogue:
	for dialogue : Dialogue in character_ref.dialogues:
		if dialogue.dialogue_name == dialogue_name:
			return dialogue
	return null

## Opens the next page of dialogue based on the choice made by the player.
## If no window name, then close the dialogue.
func next_dialogue(choice : DialogueChoice) -> void:
	if choice.next_dialogue_name == "":
		close_window()
		return
	set_dialogue(choice.next_dialogue_name)

## Executes each dialogue effect based on the given strings.
func execute_dialogue_effects(dialogue_effects : Array[String]) -> void: #NOTE: Choices point to file paths which can return null if file path changes.
	for effect in dialogue_effects: ## For each file path,
		## List of potential effect names that are valid
		match effect:
			"finished_greeting":
				character_ref.finished_greeting() #NOTE: This is not a built-in function for character and must be manually declared in child.
				continue
		print("No Dialogue Effect with name " + effect)

## Opens the shop window and closes the current dialogue window.
## Uses transaction information from the character to set up the shop window.
func open_shop() -> void:
	close_window()
	character_ref.open_shop_from_dialogue()

#DEPRECATED: No longer using a default dialogue field or DialogueTree typed.
## Set the value for the default dialogue page in the default dialogue tree.
#func set_default_dialogue(dialogue_name : String) -> void:
	#var dialogue : Dialogue = find_dialogue(dialogue_name)
	#if not dialogue:
		#print("ERROR: No dialogue with name "+dialogue_name+" found")
		#return
	#character_ref.dialogue_tree.default_dialogue = dialogue

## Goes through the list of dialogue conditions to see if they are all met.
func _are_conditions_met(conditions : Array[DialogueCondition]) -> bool:
	if not conditions:
		return true
	for condition in conditions:
		match condition.type:
			"player_att_gte":
				if not Global.focused_node.get_attribute(condition.descriptor) >= condition.value:
					return false
			"player_att_lte":
				if not Global.focused_node.get_attribute(condition.descriptor) <= condition.value:
					return false
			"player_status_is_active": print("ERROR: Not yet implemented")
				#return false
			"player_known_recipe": ## Finds a recipe ID matching the given value
				if Global.focused_node.knows_recipe_id(condition.value):
					return false
			"event_trigger": print("ERROR: Not yet implemented")
				#return false
	return true

## Sets the dialogue text
func _set_text(text : String) -> void:
	%DialogueLabel.text = text

## Adds items to DialogueOptions for the player to select as a response to what is said in the DialogueBox.
## Returns whether the options were successfully added or not
func _add_dialogue_choices(choices : Array[DialogueChoice]) -> void:
	%DialogueOptions.clear()
	
	for choice in choices:
		## Only show dialogue choices that have met the required conditions.
		if choice and _are_conditions_met(choice.conditions):
			%DialogueOptions.add_item(choice.player_response)

## Called when a dialogue option is pressed on the Character Dialogue window.
## Executes functions that the choice may cause, then opens the next dialogue window, if any.
func _on_dialogue_options_item_selected(index: int) -> void:
	if not cur_dialogue:
		print("ERROR: No current dialogue set")
		return
	var choice : DialogueChoice = cur_dialogue.choices[index]
	execute_dialogue_effects(choice.dialogue_effects)
	
	next_dialogue(choice)

## Called when the button to start trading is pressed
func _on_trade_button_pressed() -> void:
	open_shop()


func _on_button_close_pressed() -> void:
	close_window()
