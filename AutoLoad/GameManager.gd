extends Node

var coin: int = 0
var distance: float = 0.0
var is_game_over: bool = false
signal coins_changed(new_amount: int)  # Emits the updated coin amount
signal distance_increased(new_distance: int)
signal game_over
signal game_start

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

func start():
	game_start.emit()
	distance = 0.0
	coin = 0
	get_tree().set_pause(false)
	is_game_over= false
