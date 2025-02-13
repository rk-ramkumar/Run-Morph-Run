extends CanvasLayer

@onready var player_speed = $Control/PlayerSpeed
@export var player: Player
var training_scene = preload("res://Scenes/UI_training.tscn")

func _ready():
	GameManager.game_start.connect(_on_game_start)

func _on_game_start(_data):
	if GameManager.has_training and !has_node("Training"):
		_add_training()

func update_player_label(value):
	player_speed.text = str(int(value)) + "KMH"

func _add_training():
	var training = training_scene.instantiate()
	training.name = "Training"
	training.player = player
	add_child(training)

