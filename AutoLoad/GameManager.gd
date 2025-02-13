extends Node

var player_name: String = ""
var coin: int = 0
var total_coin: int = 0
var match_time: int = 180
var respawn_time: int = 5
var distance: float = 0.0
var best_distance: float = 0.0
var is_game_over: bool = false
var config_path = "user://scores.cfg"
var config = ConfigFile.new()
var has_training: bool = true
var is_online: bool = false
signal coins_changed(new_amount: int)  # Emits the updated coin amount
signal distance_increased(new_distance: int)
signal game_over
signal game_start
signal game_restart
signal training_finish
signal game_pause
signal game_resume
signal game_wait
signal request_home
signal power_activated(power: PowerData)
signal power_finished(power: PowerData)

func _ready():
	var err = config.load(config_path)

	# If the file didn't load, ignore it.
	if err != OK:
		config.set_value("player", "best_score", int(best_distance))
		config.set_value("player", "coin", coin)
		config.set_value("player", "has_training", has_training)
		config.set_value("player", "name", player_name)
		return
	has_training = config.get_value("player", "has_training")
	best_distance = config.get_value("player", "best_score")
	total_coin = config.get_value("player", "coin")
	player_name = config.get_value("player", "name", player_name)
	

func increase_coins(amount: int = 1):
	coin += amount
	coins_changed.emit(coin)

func decrease_coins(amount: int = 1):
	coin -= amount
	coins_changed.emit(coin)

func increase_distance(value):
	distance += value
	distance_increased.emit(int(distance))

func set_player_name(value: String):
	config.set_value("player", "name", value)
	config.save(config_path)

func register_collision():
	get_tree().set_pause(true)
	handle_online_game_over() if is_online else handle_game_over()

func handle_online_game_over():
	game_wait.emit()

func respawn():
	game_restart.emit({"type": "repawn"})
	get_tree().set_pause(false)

func handle_game_over():
	game_over.emit()
	is_game_over = true
	var best_score = config.get_value("player", "best_score")
	total_coin = config.get_value("player", "coin")
	if int(distance) > best_score:
		config.set_value("player", "best_score", int(distance))
	total_coin = coin + total_coin
	config.set_value("player", "coin", total_coin)
	config.save(config_path)

func is_best_score():
	var best_score = config.get_value("player", "best_score")

	return int(distance) > best_score

func start(type: String = "start"):
	best_distance = config.get_value("player", "best_score")
	distance = 0.0
	coin = 0
	is_game_over= false
	emit_signal("game_"+type, {"type": type})
	get_tree().set_pause(false)

func set_training(value):
	has_training = value
	config.set_value("player", "has_training", has_training)
	training_finish.emit()

func pause():
	game_pause.emit()
	get_tree().set_pause(true)

func resume():
	game_resume.emit()
	get_tree().set_pause(false)

func get_profile():
	return {
		"name": player_name
	}
