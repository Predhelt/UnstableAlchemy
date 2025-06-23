extends Panel


func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	#if global.mode == &"help":
	remove_from_group("menu")
	print(get_tree().get_nodes_in_group("menu"))
	if get_tree().get_nodes_in_group("menu").is_empty():
		global.mode = &"default"
	visible = false

func open_window() -> void:
	if (global.mode == &"default" or global.mode == &"menu") and not visible:
		global.mode = &"menu"
		add_to_group("menu")
		print(get_tree().get_nodes_in_group("menu"))
		%WindowName.text = "Help: General"
		visible = true
		
		open_page_general()


func open_page_general():
	%WindowName.text = "Help: General"
	%PageGeneral.visible = true

func open_page_interactions():
	%WindowName.text = "Help: Interactions"
	%PageInteractions.visible = true
	
	%PageInteractions/LabelUse.text = ("Press \""+
		InputMap.action_get_events("use_tool")[0].as_text().replace(' (Physical)','')
		+"\" to use the currently held tool on a nearby object.")
	%PageInteractions/LabelInspect.text = ("Press \""+
		InputMap.action_get_events("inspect_object")[0].as_text().replace(' (Physical)','')
		+"\" to inspect a nearby object and get a description of it.")


func _on_button_close_pressed() -> void:
	close_window()


func _on_button_general_pressed() -> void:
	open_page_general()


func _on_button_interactions_pressed() -> void:
	open_page_interactions()


func _on_button_mortar_pestle_pressed() -> void:
	%WindowName.text = "Help: Mortar & Pestle"
	%PageMP.visible = true


func _on_button_cauldron_pressed() -> void:
	%WindowName.text = "Help: Cauldron"
	%PageCauldron.visible = true


func _on_button_merger_pressed() -> void:
	%WindowName.text = "Help: Merger"
	%PageMerger.visible = true
