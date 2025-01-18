extends Control

@onready var distance_label = $GameScoreContainer/DistanceContainer/HBoxContainer/Label
@onready var coin_label = $GameScoreContainer/CoinContainer/HBoxContainer/CoinLabel

func _ready():
	GameManager.distance_increased.connect(_update_distance_label)
	GameManager.coins_changed.connect(_update_coin_label)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	_on_game_start()

func _on_game_start():
	_update_coin_label(GameManager.coin)
	_update_distance_label(GameManager.distance)
	show()

func _on_game_over():
	hide()
	
func _update_distance_label(value):
	distance_label.text = str(int(value)).pad_zeros(6)

func _update_coin_label(value):
	coin_label.text = str(value).pad_zeros(6)
