class_name LevelManager extends Node2D

## Index of the level used to track level order.
@export var level_index: int = 0
## Identifies if the level is a chamber, which does not use external persistent node data.
@export var is_chamber: bool = false

func _ready() -> void:
	Global.current_level_path = scene_file_path
	Global.is_in_chamber = is_chamber
	if(not is_chamber and
			not UserVariables.level_started and 
			UserVariables.inventory_level_start):
		var player: Character = find_child("Player", false)
		if player: 
			for item in UserVariables.inventory_level_start.items:
				player.inventory.add_item(item.duplicate())
	UserVariables.level_started = true
	setup_level()

## Configures custom setup for a given level. Separate from _ready() to allow setup to be repeated.
func setup_level():
	pass

func save(_dir: String) -> Dictionary:
	
	var save_dict = {
	}
	return save_dict

## Called when the level is cleared. Updates relevant progression variables.
func level_cleared() -> void:
	if level_index > UserVariables.level_highest_cleared_index:
		UserVariables.level_highest_cleared_index = level_index


func change_level_and_fade(path: String):
	$SceneTransitionAnimPlayer.play("fade")
	await $SceneTransitionAnimPlayer.animation_finished
	Global.change_scene(path)
