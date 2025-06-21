extends Panel

#TODO: Add functionality for opening different help tabs.
# Add additional help tabs.

func toggle_window() -> void:
	if visible:
		close_window()
	else:
		open_window()

func close_window() -> void:
	if global.mode == &"help":
		global.mode = &"default"
		visible = false

func open_window() -> void:
	if global.mode == &"default":
		global.mode = &"help"
		%WindowName.text = "Help: General"
		visible = true
		
		open_page_general()


func open_page_general():
	%WindowName.text = "Help: General"
	%PageGeneral.visible = true

func open_page_interactions():
	%WindowName.text = "Help: Interactions"
	%PageInteractions.visible = true


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
