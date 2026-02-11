class_name ProcedureInputAction extends Resource


var id := -1 ## The ID of the input action to be checked by the procedure
var type : String = "" ## Type of input. Either Equipment or Item.


func equal(ia: ProcedureInputAction):
	if not ia:
		return false
	if type == ia.type:
		if id == ia.id:
			return true
	return false
