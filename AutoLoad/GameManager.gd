extends Node

var coin: int = 0
var distance: float = 0.0
signal coins_changed(new_amount: int)  # Emits the updated coin amount
signal distance_increased(new_distance: int)

func increase_coins(amount: int = 1):
	coin += amount
	coins_changed.emit(coin)

func decrease_coins(amount: int = 1):
	coin -= amount
	coins_changed.emit(coin)

func increase_distance(value):
	distance += value
	distance_increased.emit(int(distance))
