class_name ObstacleSpawner extends Spawner

@export var probabilities: Array = [0.3, 0.5, 0.2]  # Probabilities for each function

var obstacles_scene: Dictionary = {
	"obstacle_down": preload("res://Scenes/Obstacles/obstacles_down.tscn"),
	"obstacle_up": preload("res://Scenes/Obstacles/obstacles_up.tscn")
}


func _ready():
	if GameManager.has_training:
		spawn_interval = 5
	super._ready()

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
	if GameManager.has_training:
		return

	spawn_obstacles_by_probability()
#		if obstacle.has_node("RayCast3D") and !obstacle.get_node("RayCast3D").is_colliding():
#			_disable_object(obstacle)

func spawn_obstacles_by_probability():
	var random_value = randf()
	var cumulative = 0.0
	var obstacles = _get_inactive_objects(10)
	
	for i in probabilities.size():
		cumulative += probabilities[i]
		if random_value < cumulative:
			match i:
				0: block_lanes(obstacles)
				1: place_in_line(obstacles)
				2: place_rand_obstacles(obstacles)
			return

func place_in_line(obstacles: Array):
	var lane = randi() % 3
	var prev_z_pos = spawn_distance
	for obstacle in obstacles:
		show_obstacle(obstacle, Vector3(lanes[lane], -1, prev_z_pos))
		prev_z_pos += 40

func place_rand_obstacles(obstacles: Array):
	var values = rand_lanes()
	for i in values.size():
		var obstacle = obstacles[i]
		var z_pos = randf_range(spawn_distance, spawn_distance + (randi_range(-10, 100)))
		show_obstacle(obstacle, Vector3(values[i], -1, z_pos))

func block_lanes(obstacles: Array):
	var values = rand_lanes(2)
	var laneSize = values.size()
	var obs_up = filter_by_group(obstacles, "obstacle_up")
	var obs_down = filter_by_group(obstacles, "obstacle_down")

	if obs_up.size() < laneSize or obs_down.size() < laneSize:
		return
		
	for i in laneSize:
		var z_pos = randf_range(spawn_distance, spawn_distance + (randi_range(-50, 100)))
		for obs in [obs_down, obs_up]:
			show_obstacle(obs[i], Vector3(values[i], -1, z_pos))

func show_obstacle(obstacle, position: Vector3):
	obstacle.position = position
	obstacle.show()

func filter_by_group(obstacles: Array = [], group_name: String = ""):
	return  obstacles.filter(func(obstacle): return obstacle.is_in_group(group_name))

func rand_lanes(end: int = 3) -> Array:
	var arr = lanes.duplicate(true)
	arr.shuffle()
	return range(randi_range(0, end)).map(func(i): return arr[i])
