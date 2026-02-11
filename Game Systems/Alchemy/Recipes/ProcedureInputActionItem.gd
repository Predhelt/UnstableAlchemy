class_name ProcedureInputActionItem extends ProcedureInputAction

@export var item : Item: ## Placing the associated item here automatically overrides the ID of self.
	set(i):
		id = i.id

func _init() -> void:
	type = "item"
