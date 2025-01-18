extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $Player
@onready var game_hui = $GameHUI

@export var platform_scene = preload("res://Scenes/Platform/scifi_bridge.tscn")

var rotation_speed = 0.025
var platforms: Array = []

func _ready():
	add_platform()

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	move_platforms(delta)
	var speed_mps = player.speed * (5.0 / 18.0)  # Convert km/h to m/s
	GameManager.increase_distance(speed_mps * delta)  # Update distance in meters
	game_hui.update_player_label(player.speed)

func add_platform():
	for i in 5:
		var platform = platform_scene.instantiate()
		add_child(platform)
		if !platforms.is_empty():
			var last_platform = platforms.back()
			platform.position.z = ( platform.get_size().z * 0.5 + last_platform.get_size().z * 0.5)  + last_platform.position.z
		platforms.append(platform)

func move_platforms(delta):
	for platform in platforms:
		platform.position.z -= player.speed * delta

	var current_platform = platforms.front()
	if current_platform.position.z < -current_platform.get_size().z:
		var recycled_platform = platforms.pop_front()
		recycled_platform.position.z = platforms.back().position.z + recycled_platform.get_size().z
		platforms.append(recycled_platform)
