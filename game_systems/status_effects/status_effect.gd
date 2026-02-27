class_name StatusEffect extends Resource

## Unique ID of the status effect
@export var id : int
## Name of the status effect to be given to the player
@export var name : String
## Description to be given to the player
@export var description := ""
## Icon to be shown when the status effect is active
@export var icon := Global.blank_texture
## Identifier for the effect
@export_enum("move speed bonus", "strength bonus", "grow", "cleanse", "normalize", "self-attunement") var effect : String
## Amount/Mult to change the player's stat by. use negative value for stat reduction
@export var value := 0.0
## Duration of status effect in seconds (-1 means permanent)
@export var duration := 10.0
