## Variables related to the user that are tracked globally.
extends Node

## List of recipes known by the user.
var known_recipes : Array[Recipe]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
## Keys: IDs of recipes that have been crafted by the user.
## Values: the number of times the recipe has been crafted.
var crafted_recipes : Dictionary[int,int]
## Keys: IDs of items that have been gathered from interactable objects like plants.
## Values: Number of times gathered.
var gathered_items : Dictionary[int,int] #TODO: Never updated. Check add_item.
## List of books the user has read/used
var books_read: Array[Book]
## List of objects that have been interacted with.
## Keys: Display name of the interactable object.
## Values: Array of different tracking values: [times_grabbed, times_cut, times_combined1,...]
var interacted_objects: Dictionary[String, Array]

## Sets up and returns a dictionary that represents the persistent information
## of the user to be saved to file.
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"known_recipes" : known_recipes,
		"new_recipes" : new_recipes,
		"crafted_recipes" : crafted_recipes,
		"gathered_items" : gathered_items,
		"books_read" : books_read,
		"interacted_objects" : interacted_objects
	}
	return save_dict

## Add a recipe to the list of known recipes and new recipes if not already known.
func add_recipe(recipe : Recipe) -> void:
	if recipe not in known_recipes:
		known_recipes.append(recipe)
		new_recipes.append(recipe)
