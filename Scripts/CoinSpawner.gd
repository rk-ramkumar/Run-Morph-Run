class_name CoinSpawner extends Spawner

enum PATTERNS {
	LINE,
	ARC,
	ZIGZAG
}
var arc_pos = [1, 3, 5, 7, -5, -3, -1]

func _ready():
	if !object_scene:
		object_scene = preload("res://Scenes/Coin/powerCoin.tscn")
	super._ready()

func _handle_spawn(_delta):
	pass
	
func _recycle_object(object):
	if object.position.z < -5:
		if object.is_in_group("free"):
			_disable_object(object, object.position)
			object.remove_from_group("free")
			pool.erase(object)
		else:
			_disable_object(object)

func spawn_object(platform: Platform, obstacles: Dictionary = {}, custom_pattern: int = -1):
	var pattern = randi() % PATTERNS.size() if custom_pattern == -1 else custom_pattern
	spawn_distance = platform.position.z if custom_pattern != -1 else spawn_distance
	spawn_distance += randf_range(-10, 10)
	match  pattern:
		PATTERNS.LINE:
			spawn_straight_line(randi_range(5, 10))
		PATTERNS.ARC:
			spawn_jump_arc(randi_range(3, 7))
		PATTERNS.ZIGZAG:
			spawn_zigzag(randi_range(6, 12), obstacles)

func spawn_straight_line(spawn_amount: int = 5):
	var lane = lanes.pick_random()
	var coins = _get_inactive_objects(spawn_amount)
	var y_pos = randi() % 4 + 1
	for i in coins.size():
		var coin = coins[i]
		coin.position = Vector3(lane, y_pos, spawn_distance + i*2)
		coin.show()

func spawn_jump_arc(spawn_amount: int = 7):
	var lane = lanes.pick_random()
	var coins = _get_inactive_objects(spawn_amount)

	for i in coins.size():
		var coin = coins[i]
		var z_pos = spawn_distance + i * 1.5

		coin.position = Vector3(lane, arc_pos[i] , z_pos)
		coin.show()

func spawn_zigzag(spawn_amount: int = 6, obstacles: Dictionary = {}):
	var coins = _get_inactive_objects(spawn_amount)

	if obstacles.is_empty():
		for i in coins.size():
			var coin = coins[i]
			var lane = lanes[i % 3]
			coin.position = Vector3(lane, 1, spawn_distance + i * 3)
			coin.show()
	else:
		var start_index = 0
		for i in obstacles.data.size() - 1:
			var obs = obstacles.data[i]
			if start_index + 3 > coins.size():
				return

			for idx in randi_range(start_index, start_index + 3):
				var coin = coins[idx]
				coin.position = Vector3(obs.position.x, 1, obs.position.z + (idx+1) * 3)
				coin.show()
			start_index += 3

