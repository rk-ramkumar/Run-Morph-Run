extends Node

var coin: int = 0
var distance: float = 0.0
var is_game_over: bool = false
var config_path = "user://scores.cfg"
var config = ConfigFile.new()
var has_training: bool = true
signal coins_changed(new_amount: int)  # Emits the updated coin amount
signal distance_increased(new_distance: int)
signal game_over
signal game_start

func _ready():
	var err = config.load(config_path)

	# If the file didn't load, ignore it.
	if err != OK:
		config.set_value("player", "best_score", int(distance))
		config.set_value("player", "coin", coin)
		return
	has_training = false

func increase_coins(amount: int = 1):
	coin += amount
	coins_changed.emit(coin)

func decrease_coins(amount: int = 1):
	coin -= amount
	coins_changed.emit(coin)

func increase_distance(value):
	distance += value
	distance_increased.emit(int(distance))

func register_collision():
	get_tree().set_pause(true)
	game_over.emit()
	is_game_over = true
	var best_score = config.get_value("player", "best_score")
	var prev_coin = config.get_value("player", "coin")
	if int(distance) > best_score:
		config.set_value("player", "best_score", int(distance))
	config.set_value("player", "coin", coin + prev_coin)
	config.save(config_path)

func is_best_score():
	var best_score = config.get_value("player", "best_score")

	return int(distance) > best_score

func start():
	game_start.emit()
	distance = 0.0
	coin = 0
	get_tree().set_pause(false)
	is_game_over= false
