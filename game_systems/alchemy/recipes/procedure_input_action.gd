## An action performed by the procedure as part of a recipe.
class_name ProcedureInputAction extends Resource

## The ID of the input action to be checked by the procedure
var id := -1 
## Type of input. Either Equipment or Item.
var type : String = "" 

## Checks if the current action and given action are the same.
func equal(ia: ProcedureInputAction):
	if not ia:
		return false
	if type == ia.type:
		if id == ia.id:
			return true
	return false
