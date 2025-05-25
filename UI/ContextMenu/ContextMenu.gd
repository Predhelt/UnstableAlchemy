class_name ContextMenu extends Control

signal object_inspected()
signal object_grabbed()

@onready var menu_container := $MenuContainer
var player : Player ## Reference of the player that interacted with the object

#@export var buttons : Array[Button]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func create_inspect_button():
	var inspect_button = create_button("Inspect")
	if inspect_button:
		inspect_button.connect("pressed", _on_button_inspect_pressed)
	
func create_button(label : String) -> Button:
	var button_name = label + "Button"
	if menu_container.find_child(button_name):
		print(label + " button already created")
		return null
	var new_button := Button.new()
	new_button.name = button_name
	new_button.text = label
	menu_container.add_child(new_button)
	return new_button


func _on_button_inspect_pressed() -> void:
	object_inspected.emit()


func _on_button_tools_pressed() -> void:
	object_grabbed.emit(player) # Emits that the player has grabbed the object
