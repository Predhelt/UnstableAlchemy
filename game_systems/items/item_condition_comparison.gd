##@experimental
## The comparision of a condition of an item to its current value.
class_name ItemConditionComparison extends Resource

@export_enum("crush", "grind", "stew", "bellow") var property : String
@export_enum("<", "=", ">") var comparator : String
@export_range(0,4) var value : int
