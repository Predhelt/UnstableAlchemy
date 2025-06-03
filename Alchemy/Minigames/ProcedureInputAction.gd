class_name ProcedureInputAction extends Resource

@export_enum("item", "equipment") var type : String
@export var id := -1

func equal(ia: ProcedureInputAction):
	if not ia:
		return false
	if type == ia.type:
		if id == ia.id:
			return true
	return false
