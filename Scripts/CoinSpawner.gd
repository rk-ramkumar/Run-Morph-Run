class_name CoinSpawner extends Spawner

enum PATTERNS {
	LINE,
	ARC,
	ZIGZAG
}

func _ready():
	object_scene = preload("res://Scenes/Coin/powerCoin.tscn")
	super._ready()

func _spawn_object():
	var pattern = randi() % 3
	spawn_distance = _init_state.spawn_distance + randf_range(-10, 10)
	match  pattern:
		PATTERNS.LINE:
			spawn_straight_line(randi_range(5, 10))
		PATTERNS.ARC:
			spawn_jump_arc(randi_range(3, 7))
		PATTERNS.ZIGZAG:
			spawn_zigzag(randi_range(6, 12))

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
		var angle = lerp(-PI / 2, PI / 2, i / float(spawn_amount - 1))
		var y_pos = sin(angle) * 5  # Smooth arc
		var z_pos = spawn_distance + i * 1.5

		coin.position = Vector3(lane, y_pos , z_pos)
		coin.show()

func spawn_zigzag(spawn_amount: int = 6):
	var coins = _get_inactive_objects(spawn_amount)
	for i in coins.size():
		var coin = coins[i]
		var lane = lanes[i % 3]
		coin.position = Vector3(lane, 1, spawn_distance + i * 3)
		coin.show()
	
