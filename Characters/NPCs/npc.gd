class_name NPC extends Character

#TODO: Types of interactions with NPCs:
# Flavor text / Hint message : does not lock you into a conversation
# Other (scared, runs off / opens a passageway / etc.)

## Name of the NPC to be dislpayed. Used by the player and dialogue window to show who this NPC is.
@export var npc_name : String
## The type of interaction that occurs upon interacting with the NPC
@export_enum("none", "talk", "shop") var interaction_type : String = "talk" 
## List of transactions for the NPC shop
@export var transactions : Array[Transaction]
## List of messages that are displayed above the character
@export var passive_messages : Array[String]
## Stores the list of dialogues that the NPC uses, as well as the default
## dialogue window that displays when talked to.
var dialogues : Array[Dialogue]
## The time left before the message disappears
var message_timer := 0.0
## The time since the last message ended
var last_message_delta := 0.0

## Set references to variables and default label text
func _ready() -> void:
	$InteractArea.interact_type = interaction_type
	$InteractArea.interact_label = npc_name
	%NPCShop.player = %Player
	%StatusLabel.text = ""
	%InteractLabel.text = ""
	init_dialogues()

func _process(delta: float) -> void:
	if global.mode == &"default":
		if message_timer > 0:
			message_timer -= delta
			if message_timer <= 0:
				%StatusLabel.text = ""
		else:
			last_message_delta += delta
		## Checks if enough time has passed since the last message to say another message
		if last_message_delta > 15:
			last_message_delta = 0.0
			if not passive_messages.is_empty():
				say_random_message()

func init_dialogues():
	var dialogue_path : String = scene_file_path.rsplit("/", false, 1)[0] + "/Dialogue/Dialogues/"
	#print(dialogue_path)
	var dir := DirAccess.open(dialogue_path)
	if not dir:
		print("ERROR: No path")
		return
	
	dir.list_dir_begin()
	var file_name : String = dir.get_next()
	while file_name != "":
		var split = file_name.rsplit(".", true, 1)
		if split[1] == "tres":
			var new_dialogue : Dialogue
			var file_path : String = dialogue_path+file_name
			new_dialogue = load(file_path)
			if new_dialogue:
				dialogues.append(new_dialogue)
		file_name = dir.get_next()
	dir.list_dir_end()

## Sets up and returns a dictionary that represents the persistent information
## of the npc to be saved to file. Overrides the Character save function.
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Avoiding Vector2 for compatibility with JSON
		"pos_y" : position.y,
		"npc_name" : npc_name,
		"attributes" : global_variables.attributes,
		"inventory" : global_variables.inventory,
		"known_recipes" : global_variables.known_recipes,
		"crafted_recipes" : global_variables.crafted_recipes,
		"gathered_items" : global_variables.gathered_items,
		"books_read" : global_variables.books_read,
		"active_status_effects" : global_variables.active_status_effects,
		#"selected_tool" : selected_tool,
		"interaction_type" : interaction_type,
		"dialogues" : dialogues,
		"transactions" : transactions,
		"passive_messages" : passive_messages
	}
	return save_dict

## Open the dialogue window when talked to the current NPC is referenced to configure the dialogues.
func open_dialogue(player : Player) -> void:
	%NPCDialogue.open_window_as_npc(self, player)

## Opens the NPC shop window after configuring the transactions on the page
func open_shop() -> void:
	if transactions.size(): ## If the npc has shop transactions
		if %NPCShop.transactions.size(): ## If the shop already has populated the transaction UI
			%NPCShop.clear_transactions()
		%NPCShop.transactions = transactions
		%NPCShop.player = %Player #NOTE: This would only not be the case if the player controls a different character or multiplayer is added.
		%NPCShop.open_window()

## Does additional logic if the shop was opened from the dialogue menu
func open_shop_from_dialogue():
	open_shop()
	%NPCShop.show_back_button(%NPCDialogue)

## Adds transaction to npc's shop. #TODO: IDs cannot retrieve item icon from id. Function unusuable.
## items_buying is an array of items,
## items_buying_amount is an array of item quantities,
## items_selling is an array of items,
## items_selling_amount is an array of item quantities.
func add_shop_transaction(items_buying : Array[Item], items_buying_amount : Array[int],
		items_selling : Array[Item], items_selling_amount : Array[int]):
	var new_transaction = Transaction.new()
	new_transaction.items_buying = items_buying
	new_transaction.items_buying_amount =  items_buying_amount
	new_transaction.items_selling =  items_selling
	new_transaction.items_selling_amount =  items_selling_amount
	new_transaction.id = transactions.size()
	transactions.append(new_transaction) #NOTE: This method means that if transactions need to be removed, 
	# it is not guaranteed to be the same ID depending on the order of events.

## Removes the shop transaction of the NPC at the given index.
func remove_shop_transaction(id : int):
	for i in range(transactions.size()):
		if transactions[i].id == id:
			transactions.remove_at(i)

## Displays a random passive message over the head of the NPC
func say_random_message():
	update_message(passive_messages.pick_random())

## Changes the text of the status message and resets the timer for how long the message appears.
func update_message(message: String):
	if not message:
		return
	%StatusLabel.text = message
	message_timer = 5.0

## Called when the player interacts with the NPC when the interaction type is "talk".
## Initiates setting up the npc dialogue window.
func _on_interact_area_npc_talk(player : Player) -> void:
	open_dialogue(player)

## Called when the player interacts with the NPC when the interaction type is "shop".
## Initiates setting up the npc shop window.
func _on_interact_area_npc_shop() -> void:
	open_shop()
