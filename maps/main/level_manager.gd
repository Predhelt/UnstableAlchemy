class_name LevelManager extends Node2D

@export var level_index: int = 0
#@export var use_custom_inventory: bool = false

func _ready() -> void:
	Global.current_level_path = scene_file_path
	if(#not use_custom_inventory and
			not UserVariables.level_started and 
			UserVariables.inventory_level_start):
		var player: Character = find_child("Player", false)
		if player: 
			for item in UserVariables.inventory_level_start.items:
				player.inventory.add_item(item.duplicate())
	UserVariables.level_started = true


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
