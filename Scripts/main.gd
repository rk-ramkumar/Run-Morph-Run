extends Node3D


var rotation_speed = 0.025
@onready var world_environment = $WorldEnvironment


func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta

