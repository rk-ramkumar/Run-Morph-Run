extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $Player
@onready var game_hui = $GameHUI
@export var training_scene: PackedScene
var rotation_speed = 0.010

func _ready():
	if GameManager.has_training:
		var training = training_scene.instantiate()
		training.player = player
		add_child(training)

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	var speed_mps = player.speed * (5.0 / 18.0)  # Convert km/h to m/s
	GameManager.increase_distance(speed_mps * delta)  # Update distance in meters
	game_hui.update_player_label(player.speed)
