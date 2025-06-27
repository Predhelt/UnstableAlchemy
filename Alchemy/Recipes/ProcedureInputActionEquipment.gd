class_name ProcedureInputActionEquipment extends ProcedureInputAction

@export var action_id := -1:
	set(i):
		id = i

func _init() -> void: ##FIXME: ID initializes to -1 since the export variable is not set at this stage. Either find a different way to initialize the ID or update how the ProcedureInputActions are handled.
	type = "equipment"
