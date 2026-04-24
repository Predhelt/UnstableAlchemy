## A door that opens and closes when called by external triggers.
extends StaticBody2D

## How far the door travels to open/close (px).
const MAX_OPEN_DISTANCE := 64.0 

## The texture used for the door
@export var texture : Texture2D
## Tracks whether the door is currently open.
var is_open := false
## Number of triggers that need to be active on the door for it to open.
@export var triggers_required : int = 1
## Current [Node2D]s that are triggering the door to open.
var cur_trigger_nodes : Array[Node2D]
## Total time it takes to open this door in seconds.
@export var open_time : float 
## Total time it takes to close this door in seconds.
@export var close_time : float 
## Tracks the direction that the door opens.
@export_enum("Left", "Right", "Up", "Down") var open_direction := "Right"
## Notification message for when the door is opened. If left blank, no notification.
@export var open_notification : String = ""
## 0 = not moving, 1 = opening, 2 = closing.
var is_moving := 0 
## The position of the door when it is closed
@onready var close_pos := position 
## The default position of the door
var default_pos : Vector2
## The distance that the door is currently open
var open_dist : float 
## Tracks if there has been a call in the last frame to indicate that the door should be open
var has_open_call : bool = false

func _ready() -> void:
	default_pos = position
	$Sprite2D.texture = texture
	$AudioStreamPlayer2D.play() # Audio stream starts on and stays on.
	
## Open or close the door depending on how the door is moving.
## Door cannot open any wider than MAX_OPEN_DISTANCE.
func _physics_process(delta : float) -> void:
	if is_moving == 1: # Door is opening
		var dist = MAX_OPEN_DISTANCE * (delta / open_time)
		if open_dist < MAX_OPEN_DISTANCE:
			open_dist += dist
			if open_dist >= MAX_OPEN_DISTANCE: # Prevents moving too far #FIXME: Stutters can cause misalignment.
				_move_door_to(MAX_OPEN_DISTANCE)
				open_dist = MAX_OPEN_DISTANCE
				is_moving = false
				is_open = true
				$AudioStreamPlayer2D["parameters/switch_to_clip"] = "slam_open"
				return
			_move_door(dist)
		
		else: # Door finished opening, should have been handled already.
			print("ERROR: Door should already be opened.")
	
	elif is_moving == 2 and not has_open_call: # Door is closing
		var dist = MAX_OPEN_DISTANCE * (delta / close_time)
		if open_dist > 0:
			open_dist -= dist
			if open_dist <= 0: # Prevents moving too far
				$AudioStreamPlayer2D["parameters/switch_to_clip"] = "slam_closed"
				_move_door_to(0)
				open_dist = 0
				is_moving = false
				is_open = false
				return
			
			_move_door(-dist)
		
		else: # Door finished closing, should have been handled already.
			print("ERROR: Door should alread be closed")
	has_open_call = false

## Moves the door the given distance based on the open_direction
func _move_door(dist : float) -> void:
	match open_direction:
				"Up":
					position.y -= dist
				"Right":
					position.x += dist
				"Down":
					position.y += dist
				"Left":
					position.x -= dist

## Moves the door to the given position in the axis of open_direction
func _move_door_to(pos : float) -> void:
	match open_direction:
				"Up":
					position.y = default_pos.y - pos
				"Right":
					position.x = default_pos.x + pos
				"Down":
					position.y = default_pos.y + pos
				"Left":
					position.x = default_pos.x - pos

## Begins closing the door
func close_door(node : Node2D):
	if node in cur_trigger_nodes:
		cur_trigger_nodes.remove_at(cur_trigger_nodes.find(node))
	if cur_trigger_nodes.size() < triggers_required:
		call_deferred("_deferred_close_door")

## Checks at end of frame if [member has_open_call] is true.
## If not, then changes [member is_moving] to closing.
func _deferred_close_door():
	if cur_trigger_nodes.size() >= triggers_required:
		return
	if not has_open_call:
		if is_open == true:
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = "sliding_closed"
			is_moving = 2

## Begins opening the door
func open_door(node : Node2D):
	if node not in cur_trigger_nodes:
		cur_trigger_nodes.append(node)
	if cur_trigger_nodes.size() >= triggers_required:
		has_open_call = true
		if is_moving != 1 and (is_open == false or is_moving == 2 or (is_open == false and is_moving == 0)):
			is_moving = 1
			$AudioStreamPlayer2D["parameters/switch_to_clip"] = "sliding_open"
			if open_notification != "":
				Global.emit_notification(open_notification)
