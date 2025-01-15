extends Node

var coin: int = 0
signal coins_changed(new_amount: int)  # Emits the updated coin amount

func increase_coins(amount: int = 1):
	coin += amount
	coins_changed.emit(coin)

func decrease_coins(amount: int = 1):
	coin -= amount
	coins_changed.emit(coin)
