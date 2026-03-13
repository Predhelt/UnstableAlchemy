## Variables related to the user that are tracked globally.
extends Node

## List of recipes known by the user.
var known_recipes : Array[Recipe]
## Recipes that have not been viewed yet in the recipe page
var new_recipes: Array[Recipe]
## Keys: IDs of [Recipe]s that have been crafted by the user.
## Values: the number of times the recipe has been crafted.
var crafted_recipes : Dictionary[int, int]
## List of books the user has read/used
var books_read: Array[int]
## Keys: IDs of items that have been gathered from interactable objects like plants.
## Values: Dictionary containing names of objects that the item was gathered from and the interaction type.
## Internal dictionary returns the count for number of times the interaction was performed.
## Ex: {item_id : {[obj1_name, interaction_type1] : 1, [obj1_name, interaction_type2] : 5, [obj2_name, interaction_type1] : 15}
var gathered_items : Dictionary[int, Dictionary]
## List of grab interactions that the user has performed.
## String is the name of the object, Array is the list of grab interactions of the object and their count.
## Ex: {obj1_name : [interaction, count], obj2_name : [interaction, count]}
var objects_grab_interacted: Dictionary[String, Array]
## List of cut interactions that the user has performed.
## String is the name of the object, Array is the list of grab interactions of the object and their count.
## Ex: {obj1_name : [interaction, count], obj2_name : [interaction, count]}
var objects_cut_interacted: Dictionary[String, Array]
## List of combinations that the user has performed.
## String is the name of the object, Array is the list of combinations of the object.
var objects_combined: Dictionary[String, Array]
## The count of each item with a given item ID
var items_used: Dictionary[int, int]

## Sets up and returns a dictionary that represents the persistent information
## of the user to be saved to file.
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"known_recipes" : known_recipes,
		"new_recipes" : new_recipes,
		"crafted_recipes" : var_to_str(crafted_recipes),
		"gathered_items" : var_to_str(gathered_items),
		"books_read" : books_read,
		"objects_grab_interacted" : var_to_str(objects_grab_interacted),
		"objects_cut_interacted" : var_to_str(objects_cut_interacted),
		"objects_combined" : var_to_str(objects_combined),
		"items_used" : var_to_str(items_used)
	}
	return save_dict

## Add a recipe to the list of known recipes and new recipes if not already known.
func add_recipe(recipe : Recipe) -> void:
	if recipe not in known_recipes:
		known_recipes.append(recipe)
		new_recipes.append(recipe)
