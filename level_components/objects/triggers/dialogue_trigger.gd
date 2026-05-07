class_name DialogueTrigger extends Area2D

## The message to be displayed by default if no custom message conditions are set up.
@export var message : String
## Time the player needs (in seconds) to be in the area before the message is displayed.
## After triggering, starts repeating timer. Leaving the area resets the time.
@export var initial_wait_time : float = 0.0
## Time the player needs (in seconds) to be in the area before the message is displayed.
## Leaving the area stops the timer.
@export var repeat_wait_time : float = 0.0
## Reference to the player that is being tracked for message display.
var player_ref : Character

## Uses the reference to the player [Character] to display a message.
func show_message() -> void:
	player_ref.update_message(message)
	
## Starts the timer with the given wait time before showing the message.
## If there is no wait time, shows the message.
func start_trigger() -> void:
	if initial_wait_time > 0:
		$TimerInitial.start(initial_wait_time)
	elif initial_wait_time == 0:
		show_message()
		if repeat_wait_time > 0:
			$TimerRepeat.start(repeat_wait_time)

## Stops the timer.
func stop_trigger() -> void:
	$TimerInitial.stop()
	$TimerRepeat.stop()

## Start the timer if the player enters the area.
func _on_body_entered(body: Node2D) -> void:
	if body.is_class("CharacterBody2D") and body.is_camera_focused:
		player_ref = body
		start_trigger()

## Cancel the timer if the player enters the area.
func _on_body_exited(body: Node2D) -> void:
	if (not $TimerInitial.is_stopped() or not $TimerRepeat.is_stopped()) and body == player_ref:
		player_ref = null
		stop_trigger()


func _on_timer_initial_timeout() -> void:
	show_message()
	$TimerRepeat.start(repeat_wait_time)

func _on_timer_repeat_timeout() -> void:
	show_message()
