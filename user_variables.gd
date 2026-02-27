## Variables related to the user that are tracked globally.
extends Node

## List of recipes known by the user.
var known_recipes : Array[Recipe]
## Keys: IDs of recipes that have been crafted by the user.
## Values: the number of times the recipe has been crafted.
var crafted_recipes : Dictionary[int,int]
## Keys: IDs of items that have been gathered from interactable objects like plants.
## Values: Number of times gathered.
var gathered_items : Dictionary[int, int]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
