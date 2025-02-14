extends Control

@onready var label = $PanelContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_home_button_pressed():
	GameManager.request_home.emit()

func _on_restart_button_pressed():
	pass # Replace with function body.

func handle_complete(place, room_size):
	label.text = str(place) + " / " +str(room_size)
