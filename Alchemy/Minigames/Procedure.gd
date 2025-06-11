class_name Procedure extends Resource

@export var input_actions : Array[ProcedureInputAction] = [null, null, null, null, null]

func compare(p: Procedure) -> bool:
	for i in len(input_actions):
		if not input_actions[i]:
			if not p.input_actions[i]:
				continue
			return false
		if not input_actions[i].equal(p.input_actions[i]):
			return false
	return true
