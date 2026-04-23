## A condition that has to be met for a dialogue option do be selectable.
class_name DialogueCondition extends Resource
## The type of conditions that are able to be identified.
## Handled in character_dialogue.
## "player_att_gt": If certain player attribute is at least at threshold,
## "player_att_lt": If certain player attribute is at most at threshold,
## "player_buff_is_active": If certain buff is active on the player,
## "player_known_recipe": If certain recipe is known by the player,
## "event_trigger": If certain triggers have been activated (Ex: Quest objective)
@export_enum(
	"player_att_gte",
	"player_att_lte",
	"player_status_is_active",
	"player_known_recipe",
	"event_trigger"
	) var type : String

## The descriptor related to the type of the condition that has to be met.
## "player_att_gt": Name of the attribute (move speed, strength, mass)
## "player_att_lt": Name of the attribute (move speed, strength, mass)
## "player_status_is_active": StatusEffect ID
## "player_known_recipe": Recipe ID
## "event_trigger": If certain triggers have been activated (Ex: Quest objective)
@export var descriptor : String

## The value of the condition to be met, under the given descriptor, if any.
@export var value : int
