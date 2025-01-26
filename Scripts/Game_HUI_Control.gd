extends Control

@onready var distance_label = $GameScoreContainer/DistanceContainer/HBoxContainer/Label
@onready var coin_label = $GameScoreContainer/CoinContainer/HBoxContainer/CoinLabel
@onready var best_distance_label = $GameScoreContainer/BestContainer/HBoxContainer/Label
@onready var pause_button = $PauseButton

func _ready():
	GameManager.distance_increased.connect(_update_distance_label)
	GameManager.coins_changed.connect(_update_coin_label)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	_on_game_start()
	if GameManager.has_training:
		pause_button.hide()
		GameManager.training_finish.connect(pause_button.show)
	hide()

func _on_game_start():
	_update_coin_label(GameManager.coin)
	_update_distance_label(GameManager.distance)
	_update_best_distance_label(GameManager.best_distance)
	show()

func _on_game_over():
	hide()
	
func _update_distance_label(value):
	distance_label.text = str(int(value)).pad_zeros(6)

func _update_coin_label(value):
	coin_label.text = str(value).pad_zeros(6)

func _update_best_distance_label(value):
	best_distance_label.text = str(int(value)).pad_zeros(6)


func _on_pause_button_pressed():
	GameManager.pause()
