extends CanvasLayer

@onready var player_speed = $Control/PlayerSpeed
@export var player: Player
var training_scene = preload("res://Scenes/UI_training.tscn")

func _ready():
	if GameManager.has_training:
		_add_training()

func update_player_label(value):
	player_speed.text = str(int(value)) + "KMH"

func _add_training():
	var training = training_scene.instantiate()
	training.player = player
	add_child(training)

