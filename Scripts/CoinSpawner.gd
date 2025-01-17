class_name CoinSpawner extends Node

enum PATTERNS {
	LINE,
	ARC,
	ZIGZAG
}
@export var spawn_pool_size: int = 20
@export var coin_scene: PackedScene = preload("res://Scenes/Coin/powerCoin.tscn")
@export var spawn_interval: float = 3.0
@export var spawn_distance: float = 100.0
@export var player: Player
var pool: Array = []
var spawn_timer: float = 0.0
var lane_offset: float

func _ready():
	lane_offset = get_parent().lane_offset
	_add_coins()

func _add_coins(amount = spawn_pool_size):
	for _i in amount:
		var coin = coin_scene.instantiate()
		_disable_coin(coin)
		add_child(coin)
		pool.append(coin)

func _process(delta):
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0.0
		spawn_interval = randf_range(1.0, 5.0)
		spawn_coins()
	move_coins(delta)

func move_coins(delta):
	for coin in _get_active_coins():
		coin.position.z -=  player.speed * delta
		recycle_coin(coin)

func _get_active_coins():
	return pool.filter(func(coin): return coin.visible)

func _get_inactive_coins(amount: int):
	var inactive_coins = pool.filter(func(coin): return !coin.visible)
	if inactive_coins.size() < amount:
		_add_coins(amount - inactive_coins.size())
		inactive_coins = pool.filter(func(coin): return !coin.visible)
	return inactive_coins

func recycle_coin(coin):
	if coin.position.z < -5:
		_disable_coin(coin)

func _disable_coin(coin):
	coin.position = Vector3(-10, -10, -10)
	coin.visible = false

func spawn_coins():
	var pattern = randi() % 3
	match  pattern:
		PATTERNS.LINE:
			spawn_straight_line()
		PATTERNS.ARC:
			spawn_jump_arc()
		PATTERNS.ZIGZAG:
			spawn_zigzag()

func spawn_straight_line(spawn_amount: int = 5):
	var lane = [-lane_offset, 0, lane_offset].pick_random()
	var coins = _get_inactive_coins(spawn_amount)

	for i in spawn_amount:
		var coin = coins[i]
		coin.position = Vector3(lane, 1, spawn_distance + i*2)
		coin.visible = true

func spawn_jump_arc(spawn_amount: int = 7):
	var lane = [-lane_offset, 0, lane_offset].pick_random()
	var coins = _get_inactive_coins(spawn_amount)

	for i in spawn_amount:
		var coin = coins[i]
		var angle = lerp(-PI / 2, PI / 2, i / float(spawn_amount - 1))
		var y_pos = sin(angle) * 5  # Smooth arc
		var z_pos = spawn_distance + i * 1.5

		coin.position = Vector3(lane, y_pos , z_pos)
		coin.visible = true

func spawn_zigzag(spawn_amount: int = 6):
	var lanes = [-lane_offset, 0, lane_offset]
	var coins = _get_inactive_coins(spawn_amount)
	for i in spawn_amount:
		var coin = coins[i]
		var lane = lanes[i % 3]
		coin.position = Vector3(lane, 1, spawn_distance + i * 3)
		coin.visible = true
	
