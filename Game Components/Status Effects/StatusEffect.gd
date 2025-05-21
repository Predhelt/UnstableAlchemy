class_name StatusEffect extends Resource

@export var ID : int ## Unique ID of the status effect
@export var name : String ## Name of the status effect to be given to the player
@export var description := "" ## Description to be given to the player
@export var icon := global.blank_texture ## Icon to be shown when the status effect is activeaw
@export var player_stat := "" ## The player's stat to be changed by the status effect
@export var other := "" ## Other identifiers for effects that are not direct stat changes (separated with spaces)
@export var value := 0.0 ## Amount to change the player's stat by. use negative value for stat reduction
@export var duration := 10.0 ## Duration of status effect in seconds (-1 means permanent)
