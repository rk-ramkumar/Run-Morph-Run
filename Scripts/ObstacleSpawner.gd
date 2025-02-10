class_name ObstacleSpawner extends Spawner

@export var probabilities: Array = [0.4, 0.3, 0.1, 0.2]  # Probabilities for each function
@export var coin_spawner: CoinSpawner
var last_line_lane: int = -1
var prev_obstacles = {}
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
	pass

func _recycle_object(object):
	if object.position.z < -5:
		_disable_object(object)

func spawn_object(platform: Platform):
	if GameManager.has_training or platform.name.contains("empty"):
		return

	prev_obstacles = spawn_obstacles_by_probability(platform)
	if GameManager.distance > 1000 and randf() < 0.7:
		prev_obstacles = spawn_obstacles_by_probability(platform, 0.4)

func spawn_obstacles_by_probability(platform: Platform, value = null):
	var obstacles = _get_inactive_objects(10)
	spawn_distance = platform.position.z

	var cumulative = 0.0
	var random_value = randf() if !value else value
	for i in probabilities.size():
		cumulative += probabilities[i]
		if random_value < cumulative:
			match i:
				0: 
					var line_obstacles = place_in_line(obstacles, platform)
					coin_spawner.spawn_object(platform, line_obstacles, coin_spawner.PATTERNS.ZIGZAG)
					return line_obstacles
				1: 
					return block_lanes(obstacles, platform)
				2: 
					coin_spawner.spawn_object(platform, prev_obstacles, coin_spawner.PATTERNS.LINE)
				3:
					coin_spawner.spawn_object(platform, prev_obstacles, coin_spawner.PATTERNS.ZIGZAG)
			return {}

func place_in_line(obstacles: Array, platform: Platform):
	last_line_lane = randi() % lanes.size()
	obstacles.resize(min(obstacles.size(), (randi() % 6 + 3)))
	var limit = platform.get_size().z * 0.5
	var prev_z_pos = spawn_distance - limit
	var result = {"type": "line", "data": [], "lanes": [last_line_lane]}

	for obstacle in obstacles:
		if prev_z_pos > spawn_distance + limit:
			return result
		if prev_z_pos > spawn_distance - limit:
			show_obstacle(obstacle, Vector3(lanes[last_line_lane], -1, prev_z_pos))
			result.data.append(obstacle)
		prev_z_pos += randi_range(20, 40)

	return result

func place_rand_obstacles(obstacles: Array, platform: Platform):
	var values = rand_lanes()
	var limit = (platform.get_size().z * 0.5) - 10
	for i in values.size():
		var obstacle = obstacles[i]
		var z_pos = randf_range(spawn_distance, spawn_distance + (randi_range(-limit, limit)))
		show_obstacle(obstacle, Vector3(values[i], -1, z_pos))

func block_lanes(obstacles: Array, platform: Platform):
	var values = rand_lanes(2, last_line_lane)
	last_line_lane = -1
	var laneSize = values.size()
	var obs_up = filter_by_group(obstacles, "obstacle_up")
	var obs_down = filter_by_group(obstacles, "obstacle_down")
	var result = {"type": "block", "data": [], "lanes": values}

	if obs_up.size() < laneSize or obs_down.size() < laneSize:
		return result

	var limit = (platform.get_size().z * 0.5) - 10

	for i in laneSize:
		var z_pos = randi_range(spawn_distance - limit, spawn_distance + limit)
		for obs in [obs_down, obs_up]:
			show_obstacle(obs[i], Vector3(values[i], -1, z_pos))
		result.data.append(obs_up[i])
	
	return result

func show_obstacle(obstacle, position: Vector3):
	obstacle.position = position
	obstacle.show()

func filter_by_group(obstacles: Array = [], group_name: String = ""):
	return  obstacles.filter(func(obstacle): return obstacle.is_in_group(group_name))

func rand_lanes(end: int = 3, remove_at: int = -1 ) -> Array:
	var arr: Array = lanes.duplicate(true)
	if remove_at != -1:
		arr.remove_at(remove_at)
	arr.shuffle()
	return range(
		randi_range(0, min(arr.size(), end))).map(func(i): return arr[i]
		)
