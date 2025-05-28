extends Control


func _ready() -> void:
	pass
	#%Cauldron.inventory_ref = get_parent()
	#%MortarPestle.inventory_ref = get_parent()

func toggle_window() -> void:
	visible = !visible # Flip visibility of the inventory

func close_window() -> void:
	visible = false
