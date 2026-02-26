class_name CharacterVariables extends Resource

## Reference to the inventory resource of the character(s).
@export var inventory : Inventory
## The character's stats that determine interactions with the environment
@export var attributes : Attributes
## The list of status effects that are currently active on the character
@export var active_status_effects : Array[StatusEffect]
## List of recipes known by the character. Easy to edit.
@export var known_recipes : Array[Recipe]
## Tracks whether the character is being controlled by the player
var is_controlled : bool = false
## Tracks whether the camera is focused on the character
var is_camera_focused : bool = false
## Keys: IDs of recipes that have been crafted by the player.
## Values: the number of times the recipe has been crafted.
var crafted_recipes : Dictionary[int,int]
## Keys: IDs of items that have been gathered from interactable objects like plants.
## Values: Number of times gathered.
var gathered_items : Dictionary[int, int]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
## The currently selected tool that the character is holding
#var selected_tool : StringName = &"hand"
## List of books by ID that the character has read
var books_read : Array[int]
