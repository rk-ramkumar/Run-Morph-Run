extends Node3D


var rotation_speed = 0.025
@onready var world_environment = $WorldEnvironment
@onready var mesh_instance = $MeshInstance3D
@onready var mesh_instance_2 = $MeshInstance3D2
@onready var mesh_instance_3 = $MeshInstance3D3

@onready var player = $cr7
var platforms = []

func _ready():
	platforms.append(mesh_instance)
	platforms.append(mesh_instance_2)
	platforms.append(mesh_instance_3)

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	move_platforms(delta)
	add_platform()

func add_platform():
	if platforms.size() == 2:
		return

func move_platforms(delta):
	for platform in platforms:
		platform.position.z -= player.speed * delta

	var current_platform = platforms.front()
	if current_platform.position.z < -current_platform.get_aabb().size.z:
		var recycled_platform = platforms.pop_front()
		recycled_platform.position.z = platforms.back().position.z + recycled_platform.get_aabb().size.z
		platforms.append(recycled_platform)
