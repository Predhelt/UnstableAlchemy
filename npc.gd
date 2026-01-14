class_name NPC extends CharacterBody2D

#TODO: Types of interactions with NPCs:
# Flavor text / Hint message : does not lock you into a conversation
# Conversation text
# Other (scared, runs off / opens a passageway / etc.)

#TODO: consider different types of conversations and how to easily swap between them (consider export)
# Also, any dialogue window should prevent other menus from opening.

@export var npc_name : String
@export var transactions : Array[Transaction] ##List of transactions for the NPC shop
@export_enum("talk", "shop") var interaction_type : String = "talk" ##The type of interaction that occurs upon interacting with the NPC

func _ready() -> void:
	$InteractArea.interact_type = interaction_type
	%NPCShop.player = %Player

func open_dialogue() -> void:
	%NPCDialog.open_window(self) ##TODO: Implement open_dialogue
	# window.open

func close_dialogue() -> void:
	pass
	# window.resetandclose()

func open_shop() -> void:
	print("opening window")
	
	if transactions.size(): #If the npc has shop transactions
		if %NPCShop.transactions.size(): #If the shop already has populated the transaction UI
			%NPCShop.clear_transactions()
		%NPCShop.transactions = transactions
		%NPCShop.open_window()


func _on_interact_area_npc_talk() -> void:
	open_dialogue()

func _on_interact_area_npc_shop() -> void:
	open_shop()

func _on_interact_area_grab():
	pass

func _on_interact_area_cut():
	pass

func _on_interact_area_dropper():
	pass
