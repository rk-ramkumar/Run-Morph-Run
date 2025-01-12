extends Node3D

@onready var world_environment = $WorldEnvironment
@onready var player = $cr7
@onready var fantasy_island = $fantasy_island
var rotation_speed = 0.025
var platform_scene = preload("res://Scenes/Blocks/Grass/low_large.tscn")
var platforms: Array = []

func _ready():
	add_platform()
	var tween = get_tree().create_tween()
	tween.tween_property(fantasy_island, "position:z", -20, 3)
	tween.tween_callback(func(): fantasy_island.visible = false)

func _process(delta):
	world_environment.environment.sky_rotation.y += rotation_speed * delta
	move_platforms(delta)

func add_platform():
	for i in 50:
		var platform = platform_scene.instantiate()
		if !platforms.is_empty():
			platform.position.z = platforms.back().position.z + 1
		add_child(platform)
		platforms.append(platform)

func move_platforms(delta):
	for platform in platforms:
		platform.position.z -= player.speed * delta

	var current_platform = platforms.front()
	if current_platform.position.z < -current_platform.get_aabb().size.z:
		var recycled_platform = platforms.pop_front()
		recycled_platform.position.z = platforms.back().position.z + recycled_platform.get_aabb().size.z
		platforms.append(recycled_platform)
