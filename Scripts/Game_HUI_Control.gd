extends Control

@onready var distance_label = $GameScoreContainer/DistanceContainer/HBoxContainer/Label
@onready var coin_label = $GameScoreContainer/CoinContainer/HBoxContainer/CoinLabel
@onready var best_distance_label = $GameScoreContainer/BestContainer/HBoxContainer/Label
@onready var pause_button = $PauseButton
@onready var best_distance = $GameScoreContainer/BestContainer/HBoxContainer/BestDistance
@onready var online_control = $OnlineControl
@onready var online_timer_label = $OnlineControl/OnlineTimerLabel
@onready var respawn_bg = $OnlineControl/RespawnBg
@onready var respawn_timer_label = $OnlineControl/RespawnBg/RespawnTimerLabel
@onready var complete = $"../Complete"

const best_score_texture = preload("res://Assets/Images/best-score.png")
const leaderboard_texture = preload("res://Assets/Images/winner.png")
var data

func _ready():
	GameManager.distance_increased.connect(_update_distance_label)
	GameManager.coins_changed.connect(_update_coin_label)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	GameManager.game_wait.connect(_on_game_wait)
	WebSocket.leaderboard_updated.connect(_on_leaderboard_updated)
	_on_game_start({})
	if GameManager.has_training:
		pause_button.hide()
		GameManager.training_finish.connect(pause_button.show)
	hide()
	online_control.hide()

func _on_game_start(gameData: Dictionary):
	if !gameData.is_empty() and gameData.type == "respawn":
		return
	_update_coin_label(GameManager.coin)
	_update_distance_label(GameManager.distance)
	_update_best_distance_texture()
	_update_best_distance_label(GameManager.best_distance)
	show()
	pause_button.show()
	if GameManager.is_online:
		online_control.show()
		pause_button.hide()
		var tween = create_tween()
		tween.tween_method(_update_timer_label, 0, GameManager.match_time, GameManager.match_time)
		tween.tween_callback(_on_time_over)

func _on_game_over():
	hide()

func _update_best_distance_texture():
	best_distance.texture = leaderboard_texture if GameManager.is_online else best_score_texture

func _update_distance_label(value):
	distance_label.text = str(int(value)).pad_zeros(6)

func _update_coin_label(value):
	coin_label.text = str(value).pad_zeros(6)

func _update_best_distance_label(value):
	if GameManager.is_online:
		return
	best_distance_label.label_settings.font_color = Color('39ff14')
	best_distance_label.text = str(int(value)).pad_zeros(6)

func _on_pause_button_pressed():
	GameManager.pause()

func _update_timer_label(value):
	online_timer_label.text = str(GameManager.match_time - value)

func _on_time_over():
	complete.handle_complete(data.place, data.room_size)

func _on_wait_time_over():
	respawn_bg.hide()
	GameManager.respawn()

func _on_game_wait():
	respawn_bg.show()
	var tween = create_tween()
	tween.tween_method(animate, 0, GameManager.respawn_time,  GameManager.respawn_time)
	tween.tween_callback(_on_wait_time_over)

func animate(value):
	respawn_timer_label.text = "respawn in\n" + str(GameManager.respawn_time - value)

func _on_leaderboard_updated(msg):
	data = msg
	var ratio = (msg.place - 1) / msg.room_size
	var colors = {
		ratio < 1: "red",
		ratio < 0.7: "yellow",
		ratio < 0.3: "39ff14"
	}
	best_distance_label.label_settings.font_color = Color(colors[true])
	best_distance_label.text = str(msg.place)
