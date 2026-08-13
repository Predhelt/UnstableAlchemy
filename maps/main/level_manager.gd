class_name LevelManager extends Node2D

@export var level_index: int = 0
@export var reset_inventory_on_start: bool = false

func _ready() -> void:
	Global.current_level_path = scene_file_path
	if(not reset_inventory_on_start and
			not UserVariables.level_started and UserVariables.inventory_level_start):
		var player: Character = find_child("Player", false)
		if player: player.inventory = UserVariables.inventory_level_start.duplicate(true)
	UserVariables.level_started = true


func save(_dir: String) -> Dictionary:
	#var cur_path : String = "%s/%s" % [dir, name]
	#if not DirAccess.dir_exists_absolute(cur_path):
		#DirAccess.make_dir_recursive_absolute(cur_path)
	#
	#var player_init_inv_path : String = "%s/player_initial_inventory.tres" % [cur_path]
	#if player_initial_inventory:
		#ResourceSaver.save(player_initial_inventory, player_init_inv_path)
	#else:
		#player_init_inv_path = ""
	
	var save_dict = {
		#"player_init_inv_path" : player_init_inv_path
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
