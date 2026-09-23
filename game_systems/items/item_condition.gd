## An effect that is added or removed form an item when comparisons are satisfied.
class_name ItemCondition extends Resource

## List of status effects that will be added when comparisons are satisfied.
@export var effects_added : Array[StatusEffect]
## List of status effects that will be removed when comparisons are satisfied.
@export var effects_removed : Array[StatusEffect]
## List of events that will be added when comparisons are satisfied.
@export var events_added : Array[String]
## List of events that will be removed when comparisons are satisfied.
@export var events_removed : Array[String]
## List of comparisons that need to be satisfied for condition to be triggered
@export var comparisions : Array[ItemConditionComparison]
