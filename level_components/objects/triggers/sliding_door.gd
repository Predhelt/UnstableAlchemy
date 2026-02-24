extends StaticBody2D

## How far the door travels to open/close (px).
const MAX_OPEN_DISTANCE := 64.0 

## Tracks whether the door is currently open.
var is_open := false
## Total time it takes to open this door.
@export var open_time : float 
## Total time it takes to close this door.
@export var close_time : float 
## Tracks the direction that the door opens.
## 0 = Up, 1 = Right, 2 = Down, 3 = Left.
@export var open_direction := 0
## 0 = not moving, 1 = opening, 2 = closing.
var is_moving := 0 
## The position of the door when it is closed
@onready var close_pos := position 
## The default position of the door
var default_pos : Vector2
## The distance that the door is currently open
var open_dist : float 

func _ready() -> void:
	default_pos = position
	
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
				return
			_move_door(dist)
		
		else: # Door finished opening, should have been handled already.
			print("ERROR: Door should already be opened.")
	
	elif is_moving == 2: # Door is closing
		var dist = MAX_OPEN_DISTANCE * (delta / close_time)
		if open_dist > 0:
			open_dist -= dist
			if open_dist <= 0: # Prevents moving too far
				_move_door_to(0)
				open_dist = 0
				is_moving = false
				is_open = false
				return
			
			_move_door(-dist)
		
		else: # Door finished closing, should have been handled already.
			print("ERROR: Door should alread be closed")

## Moves the door the given distance based on the open_direction
func _move_door(dist : float) -> void:
	match open_direction:
				0: # Up
					position.y -= dist
				1: # Right
					position.x += dist
				2: # Down
					position.y += dist
				3: # Left
					position.x -= dist

## Moves the door to the given position in the axis of open_direction
func _move_door_to(pos : float) -> void:
	match open_direction:
				0: # Up
					position.y = default_pos.y - pos
				1: # Right
					position.x = default_pos.x + pos
				2: # Down
					position.y = default_pos.y + pos
				3: # Left
					position.x = default_pos.x - pos

func close_door():
	is_moving = 2


func open_door():
	is_moving = 1
