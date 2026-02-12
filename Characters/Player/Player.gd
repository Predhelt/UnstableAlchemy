## The playable character
class_name Player extends Character

## Update player position and messages every frame
func _physics_process(delta: float) -> void:
	if global.mode != &"default":
		return
	
	_move_character(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	
	for rb in pushing_bodies:
		_push_body(rb)
	
	_update_status_effect_timers(delta)

	if status_message_timer > 0:
		status_message_timer -= delta
		if status_message_timer <= 0:
			%StatusLabel.text = ""

## Handles input action events
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if global.mode == &"default": ## Only execute interaction in appropriate mode
			execute_interaction()
	if event.is_action_pressed("use_tool"):
		if global.mode == &"default": ## Only execute tool in appropriate mode
			execute_tool()
