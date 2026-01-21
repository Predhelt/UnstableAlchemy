class_name NPC extends CharacterBody2D

#TODO: Types of interactions with NPCs:
# Flavor text / Hint message : does not lock you into a conversation
# Other (scared, runs off / opens a passageway / etc.)

#TODO: consider different types of conversations and how to easily swap between them (consider export)
# Also, any dialogue window should prevent other menus from opening. (ex: the Recipe Menu)

## Name of the NPC to be dislpayed. Used by the player and dialogue window to show who this NPC is.
@export var npc_name : String
## List of attributes that influence how the character interacts with the environment.
@export var attributes : Attributes
## The type of interaction that occurs upon interacting with the NPC
@export_enum("none", "talk", "shop") var interaction_type : String = "talk" 
## Stores the list of dialogues that the NPC uses, as well as the default dialogue window that displays when talked to.
@export var dialogue_tree : DialogueTree
## List of transactions for the NPC shop
@export var transactions : Array[Transaction]
## List of messages that are displayed above the character
@export var passive_messages : Array[String]
## The time left before the message disappears
var message_timer := 0.0
## The time since the last message ended
var last_message_delta := 0.0


## Keeps track of if the path was already cleared
var is_path_cleared := false


## Set references to variables
func _ready() -> void:
	$InteractArea.interact_type = interaction_type
	$InteractArea.interact_label = npc_name
	%NPCShop.player = %Player
	self.get_parent().connect("pathway_cleared", _on_pathway_cleared)


func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			$Message.text = ""
	else:
		last_message_delta += delta
	## Checks if enough time has passed since the last message to say another message
	if last_message_delta > 15:
		last_message_delta = 0.0
		say_random_message()

## Open the dialogue window when talked to the current NPC is referenced to configure the dialogues.
func open_dialogue() -> void:
	%NPCDialogue.open_window_as_npc(self)

## Opens the NPC shop window after configuring the transactions on the page
func open_shop() -> void:
	if transactions.size(): ## If the npc has shop transactions
		if %NPCShop.transactions.size(): ## If the shop already has populated the transaction UI
			%NPCShop.clear_transactions()
		%NPCShop.transactions = transactions
		%NPCShop.open_window()

## Does additional logic if the shop was opened from the dialogue menu
func open_shop_from_dialogue():
	open_shop()
	%NPCShop.show_back_button(%NPCDialogue)

## Displays a random passive message over the head of the NPC
func say_random_message():
	update_message(passive_messages.pick_random())

## Changes the text of the status message and resets the timer for how long the message appears.
func update_message(message: String):
	if not message:
		return
	$Message.text = message
	message_timer = 5.0

## Triggers when the pathway out of the GCSM area is cleared. Marks the completion of the world.
func _on_pathway_cleared():
	if not is_path_cleared:
		update_message("Thank you for clearing the path!")
		is_path_cleared = true

## Called when the player interacts with the NPC when the interaction type is "talk".
## Initiates setting up the npc dialogue window.
func _on_interact_area_npc_talk() -> void:
	open_dialogue()

## Called when the player interacts with the NPC when the interaction type is "shop".
## Initiates setting up the npc shop window.
func _on_interact_area_npc_shop() -> void:
	open_shop()
