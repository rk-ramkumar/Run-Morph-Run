extends Control

@onready var distance_label = $VBoxContainer/DistanceContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.distance_increased.connect(_update_distance_label)

func _update_distance_label(value):
	distance_label.text = str(int(value)).pad_zeros(6)
