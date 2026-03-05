## Variables related to the user that are tracked globally.
extends Node

## List of recipes known by the user.
var known_recipes : Array[Recipe]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
## Keys: IDs of recipes that have been crafted by the user.
## Values: the number of times the recipe has been crafted.
var crafted_recipes : Dictionary[int, int]
### Keys: IDs of items that have been gathered from interactable objects like plants.
### Values: Array containing number of times gathered.
#var gathered_items : Dictionary[int, Array] #TODO: Not implemented.
## List of books the user has read/used
var books_read: Array[Book]
## List of grab interactions that the user has performed.
## String is the name of the object, Array is the list of grab interactions of the object.
var objects_grab_interacted: Dictionary[String, Interaction]
## List of cut interactions that the user has performed.
## String is the name of the object, Array is the list of cut interactions of the object.
var objects_cut_interacted: Dictionary[String, Interaction]
## List of combinations that the user has performed.
## String is the name of the object, Array is the list of combinations of the object.
var objects_combined: Dictionary[String, Array]

## Sets up and returns a dictionary that represents the persistent information
## of the user to be saved to file.
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"known_recipes" : known_recipes,
		"new_recipes" : new_recipes,
		"crafted_recipes" : crafted_recipes,
		#"gathered_items" : gathered_items,
		"books_read" : books_read,
		"objects_grab_interacted" : objects_grab_interacted,
		"objects_cut_interacted" : objects_cut_interacted,
		"objects_combined" : objects_combined,
	}
	return save_dict

## Add a recipe to the list of known recipes and new recipes if not already known.
func add_recipe(recipe : Recipe) -> void:
	if recipe not in known_recipes:
		known_recipes.append(recipe)
		new_recipes.append(recipe)
