extends Node3D


var rotation_speed = 0.025
@onready var world_environment = $WorldEnvironment
@onready var mesh_instance = $MeshInstance3D
@onready var mesh_instance_2 = $MeshInstance3D2

@onready var player = $cr7
var platforms = []

func _ready():
	platforms.append(mesh_instance)
	platforms.append(mesh_instance_2)

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	move_platform(delta)
	add_platform()

func add_platform():
	if platforms.size() == 2:
		return

func move_platform(delta):
	var current_platform = platforms.front()
	if (current_platform.mesh.size.z) < abs(current_platform.position.z):
		platforms.append(platforms.pop_front())
		var pos = platforms.reduce(func (acc, cur): return acc + abs(cur.position.z), 0)
		platforms.back().position.z = pos

	for platform in platforms:
		platform.position.z -= player.speed * delta
