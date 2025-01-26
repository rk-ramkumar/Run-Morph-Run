extends Control

@onready var animation_player = $AnimationPlayer
@onready var distance = $DistanceContainer/DistanceLabel
@onready var coin = $CoinPanelContainer/CoinContainer/Coin
@onready var audio_stream_player = $AudioStreamPlayer
@onready var distance_texture = $DistanceContainer/DistanceTexture

var textures = {
	true : preload("res://Assets/Images/best-score.png"),
	false: preload("res://Assets/Images/distance.png")
}

func _ready():
	hide()
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)

func _on_game_start():
	hide()

func _on_game_over():
	show()
	audio_stream_player.play()
	distance_texture.texture = textures[GameManager.is_best_score()]
	distance.text = str(int(GameManager.distance))
	coin.text = str(GameManager.total_coin)
	animation_player.play("popup")
	animation_player.queue("fade")
	_animate_coin()

func _on_start_button_pressed():
	GameManager.start("restart")

func _on_exit_button_pressed():
	get_tree().quit()

func _animate_coin():
	var tween = create_tween()
	tween.tween_method(set_coin_text, GameManager.total_coin, GameManager.coin + GameManager.total_coin, 1).set_delay(0.5)
	
func set_coin_text(value: int):
	coin.text = str(value)


func _on_home_button_pressed():
	GameManager.request_home.emit()
	
