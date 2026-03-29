extends Control

## Scene for button that represents a level to be selected.
const BUTTON_LEVEL_SELECT = preload("res://maps/menu/button_level_select.tscn")

## Folder containing the levels being used to populated the level select.
@export_dir var dir_levels_path : String = "res://maps/training/"


func _ready() -> void:
	set_levels(dir_levels_path)


func set_levels(path : String) ->  void:
	var dir := DirAccess.open(path)
	if not dir:
		print("ERROR: level path directory not properly opened.")
	dir.list_dir_begin()
	var file_name : String = dir.get_next()
	while file_name != "":
		if file_name.rsplit(".")[1] == "tscn":
			#print(file_name)
			add_level_button("%s/%s" % [dir.get_current_dir(), file_name.replace('.remap','')], 
				file_name.split(".")[0].replace("_", " "))
		file_name = dir.get_next()
	dir.list_dir_end()

## Creates and adds the button representing the level at the given [param file_path].
func add_level_button(file_path : String, level_name : String) -> void:
	var button : Button = BUTTON_LEVEL_SELECT.instantiate()
	button.level_path = file_path
	button.text = level_name
	%GridContainerButtons.add_child(button)
	
