class_name ObstacleSpawner extends Spawner

var obstacles_scene: Dictionary = {
	"obstacle_down": preload("res://Scenes/Obstacles/obstacles_down.tscn"),
	"obstacle_up": preload("res://Scenes/Obstacles/obstacles_up.tscn")
}

func _add_object(amount = spawn_pool_size):
	for _i in amount:
		for obstacle_name in obstacles_scene:
			var object = obstacles_scene[obstacle_name].instantiate()
			_disable_object(object)
			add_child(object)
			object.add_to_group(obstacle_name)
			pool.append(object)
	pool.shuffle()

func _spawn_object():
	var obstacles = _get_inactive_objects(10)
	var values = rand_lanes()
	for i in values.size():
		var obstacle = obstacles[i]
		var z_pos = randf_range(spawn_distance, spawn_distance + (20 * randi_range(-1, 1)))
		obstacle.position = Vector3(values[i], 0, z_pos)
		obstacle.show()

func rand_lanes() -> Array:
	var arr = lanes.duplicate(true)
	arr.shuffle()
	return range(randi_range(0, 3)).map(func(i): return arr[i])
