extends OptionButton

var craft_precisions := [
	0.25,
	0.5,
	0.8
]

func _ready() -> void:
	select(craft_precisions.find(Global.cauldron_craft_precision))

func _on_item_selected(index: int) -> void:
	Global.cauldron_craft_precision = craft_precisions[index]
