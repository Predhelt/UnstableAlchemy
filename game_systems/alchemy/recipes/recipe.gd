## Describes the process for producing the given items using the given ingedients and tool.
class_name Recipe extends Resource

## Unique identifier for recipe. -1 is unused. 0-99 are M&P. 100-199 are Mergers. 500+ are Potions. 999 is failed craft
@export var id : int 

# Outputs
## The item produced by the recipe
@export var product_item : Item 
## The amount of items produced by the recipe
@export_range(0, 100) var product_item_amount := 0 
## The time it takes to craft the recipe
@export_range(0.0, 10.0) var product_craft_time := 0.0 

# Inputs
## The tool used in the craft
var tool_used : StringName
## The ingredients used in the craft
@export var ingredients : Array[Item] 
## The procedure to be followed to create the product
@export var procedure : Procedure 
