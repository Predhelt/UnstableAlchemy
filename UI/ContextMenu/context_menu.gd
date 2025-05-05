extends Control

signal item_grabbed()
#@onready var item = get_parent().get_parent() # Context menu is child of Interact Area which is child of the object
#@export var buttons : Array[Button]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%InspectionPanel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_inspect_pressed() -> void:
	var inspection_panel = %InspectionPanel
	inspection_panel.visible = true
	self.visible = false


func _on_button_grab_pressed() -> void:
	item_grabbed.emit()
