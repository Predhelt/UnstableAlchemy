extends OptionButton

## Multipliers of the speed of the minigame based off of the difficulty set.
var craft_speed_mults := [
	1.0,
	1.5,
	3.0
]

func _ready() -> void:
	select(craft_speed_mults.find(Global.cauldron_craft_speed_mult))

func _on_item_selected(index: int) -> void:
	Global.cauldron_craft_speed_mult = craft_speed_mults[index]
