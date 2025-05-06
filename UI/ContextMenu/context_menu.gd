extends Control

signal object_inspected()
signal object_grabbed()
#@onready var object = get_parent().get_parent() # Context menu is child of Interact Area which is child of the object
#@export var buttons : Array[Button]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%InspectionPanel.visible = false


func _on_button_inspect_pressed() -> void:
	object_inspected.emit()
	var inspection_panel = %InspectionPanel
	inspection_panel.visible = true
	self.visible = false


func _on_button_grab_pressed() -> void:
	object_grabbed.emit()
