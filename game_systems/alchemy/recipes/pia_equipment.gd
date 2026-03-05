## A ProcedureInputAction that represents Equipment being used.
class_name ProcedureInputActionEquipment extends ProcedureInputAction

## Used to overwrite the inherited ID variable in the editor.
@export var action_id := -1:
	set(i):
		id = i

## Sets the inherited type variable to "equipment" upon creation.
func _init() -> void:
	type = "equipment"
