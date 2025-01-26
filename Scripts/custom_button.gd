extends PanelContainer

signal pressed
@onready var button = $Button
@onready var label = $Button/Label
@export var text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = text

func _on_button_pressed():
	pressed.emit()
