class_name CoinSpawner extends Node

enum PATTERNS {
	LINE,
	ARC,
	ZIGZAG
}
@export var spawn_pool_size: int = 20
@export var coin_scene: PackedScene = preload("res://Scenes/Coin/powerCoin.tscn")
@export var spawn_interval: float = 10.0
@export var player: Player
var pool: Array = []
var spawn_timer: float = 0.0
var lane_offset: float

func _ready():
	lane_offset = get_parent().lane_offset
	add_coin()

func add_coin(amount = spawn_pool_size):
	for i in spawn_pool_size:
		var coin = coin_scene.instantiate()
		_disable(coin)
		add_child(coin)
		pool.append(coin)

func _process(delta):
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0.0
		spawn_interval = randf_range(1.0, 10.0)
		spawn_coin()
	move_coin(delta)

func move_coin(delta):
	for coin in _get_active_coins():
		coin.position.z -=  player.speed * delta
		recycle_coin(coin)

func _get_active_coins():
	return pool.filter(func(coin): return coin.visible)

func _get_inactive_coins():
	return pool.filter(func(coin): return !coin.visible)

func recycle_coin(coin):
	if coin.position.z < -5:
		_disable(coin)

func _disable(coin):
	coin.position.z = -5
	coin.visible = false

func spawn_coin():
	var pattern = randi() % 3
	match  pattern:
		PATTERNS.LINE:
			spawn_straight_line()
		PATTERNS.ARC:
			spawn_straight_line()
		PATTERNS.ZIGZAG:
			spawn_straight_line()

func spawn_straight_line(spawn_amount: int = 5):
	var lane = [lane_offset, 0, -lane_offset].pick_random()
	var coins = _get_inactive_coins()
	if coins.size() < spawn_amount:
		add_coin(spawn_amount - coins.size())
		coins = _get_inactive_coins()
	for i in spawn_amount:
		var coin = coins[i]
		coin.position = Vector3(lane, 1, 40 + i*2)
		coin.visible = true
