extends StaticBody2D

var is_open := false
@export var open_time : float ## Total time it takes to open this door
@export var close_time : float ## Total time it takes to close this door
@export var is_opening_left := true ## Tracks whether the door is opening to the left or the right
var is_moving := 0 ## 0 = not moving, 1 = opening, 2 = closing
const MAX_OPEN_DISTANCE := 128.0 ## How far the door travels to open/close (px)
@onready var close_pos := position ## The position of the door when it is closed
var open_dist : float ## The distance that the door is currently open

#func _ready() -> void:
	

func _physics_process(delta: float) -> void:
	if is_moving == 1: # Door is opening
		var dist = MAX_OPEN_DISTANCE * (delta / open_time)
		if open_dist < MAX_OPEN_DISTANCE:
			open_dist += dist
			
			if is_opening_left:
				position.x -= dist
			else:
				position.x += dist
			
		else: # Door just finished opening
			is_moving = false
			is_open = true
			
	elif is_moving == 2: # Door is closing
		var dist = MAX_OPEN_DISTANCE * (delta / close_time)
		if open_dist > 0:
			open_dist -= dist
			
			if is_opening_left:
				position.x += dist
			else:
				position.x -= dist
		
		else: # Door just finished closing
			is_moving = false
			is_open = false
			#clear_door()


func close_door():
	is_moving = 2

func open_door():
	is_moving = 1

#func clear_door():
	## Remove the player from the door
	#get_collision_exceptions()
	#if 
