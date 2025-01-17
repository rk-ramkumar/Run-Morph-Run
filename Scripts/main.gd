extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $Player
@export var platform_scene = preload("res://Scenes/Platform/scifi_bridge.tscn")
@export var lane_offset: float = 2.5
var rotation_speed = 0.025
var platforms: Array = []

func _ready():
	add_platform()

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	move_platforms(delta)

func add_platform():
	for i in 5:
		var platform = platform_scene.instantiate()
		add_child(platform)
		if !platforms.is_empty():
			platform.position.z = platform.get_aabb().size.z + platforms.back().position.z
		platforms.append(platform)

func move_platforms(delta):
	for platform in platforms:
		platform.position.z -= player.speed * delta

	var current_platform = platforms.front()
	if current_platform.position.z < -current_platform.get_aabb().size.z:
		var recycled_platform = platforms.pop_front()
		recycled_platform.position.z = platforms.back().position.z + recycled_platform.get_aabb().size.z
		platforms.append(recycled_platform)
