class_name DialogueTrigger extends Area2D

## The message to be displayed by default if no custom message conditions are set up.
@export var message : String
## Time the player needs (in seconds) to be in the area before the message is displayed.
## Leaving the area resets the time.
@export var wait_time : float = 0.0
## Reference to the player that is being tracked for message display.
var player_ref : Character

## Uses the reference to the player [Character] to display a message.
func show_message() -> void:
	player_ref.update_message(message)
	
## Starts the timer with the given wait time before showing the message.
## If there is no wait time, shows the message.
func start_trigger() -> void:
	if wait_time > 0:
		$Timer.start(wait_time)
	elif wait_time == 0:
		show_message()

## Stops the timer.
func stop_trigger() -> void:
	$Timer.stop()

## Start the timer if the player enters the area.
func _on_body_entered(body: Node2D) -> void:
	if body.is_class("CharacterBody2D") and body.is_camera_focused:
		player_ref = body
		start_trigger()

## Cancel the timer if the player enters the area.
func _on_body_exited(body: Node2D) -> void:
	if not $Timer.is_stopped() and body == player_ref:
		player_ref = null
		stop_trigger()


func _on_timer_timeout() -> void:
	show_message()
