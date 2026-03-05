## A ProcedureInputAction that represents and Item being used.
class_name ProcedureInputActionItem extends ProcedureInputAction

## Placing the associated item here automatically overrides the ID of self.
@export var item : Item:
	set(i):
		id = i.id

func _init() -> void:
	type = "item"
