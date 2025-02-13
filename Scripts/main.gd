extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $Player
@onready var game_hui = $GameHUI
@export var training_scene: PackedScene
var rotation_speed = 0.010
@onready var audio_stream_player = $AudioStreamPlayer3D

func _ready():
	GameManager.game_start.connect(_on_game_start)
	GameManager.request_home.connect(_on_request_home)
	set_process(false)
	hide()

func _on_request_home():
	set_process(false)
	audio_stream_player.stop()
	hide()

func _on_game_start(_data):
	show()
	audio_stream_player.play(1.0)
	if GameManager.has_training and !has_node("Training"):
		var training = training_scene.instantiate()
		training.name = 'Training'
		training.player = player
		add_child(training)
	set_process(true)

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	var speed_mps = player.speed * (5.0 / 18.0)  # Convert km/h to m/s
	GameManager.increase_distance(speed_mps * delta)  # Update distance in meters
	game_hui.update_player_label(player.speed)
