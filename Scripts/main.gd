extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $Player
@onready var game_hui = $GameHUI

var rotation_speed = 0.025


func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	var speed_mps = player.speed * (5.0 / 18.0)  # Convert km/h to m/s
	GameManager.increase_distance(speed_mps * delta)  # Update distance in meters
	game_hui.update_player_label(player.speed)
