class_name NPC extends CharacterBody2D

#TODO: Types of interactions with NPCs:
# Flavor text / Hint message : does not lock you into a conversation
# Conversation text
# Other (scared, runs off / opens a passageway / etc.)

#TODO: consider different types of conversations and how to easily swap between them (consider export)
# Also, any dialogue window should prevent other menus from opening.

@export var transactions : Array[Transaction]

func open_dialogue(message : String) -> void:
	pass
	# window.open

func close_dialogue() -> void:
	pass
	# window.resetandclose()

func open_shop() -> void:
	if transactions.size():
		$NPCShop.transactions = transactions

func _on_interact_area_npc_open_shop() -> void:
	open_shop()

func _on_interact_area_npc_talk() -> void:
	pass
	#open_dialogue("How can I help you?")

func _on_interact_area_grab():
	pass

func _on_interact_area_cut():
	pass

func _on_interact_area_dropper():
	pass
