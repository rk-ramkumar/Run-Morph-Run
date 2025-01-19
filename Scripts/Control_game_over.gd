extends Control

@onready var animation_player = $AnimationPlayer
@onready var distance = $PanelContainer/VBoxContainer/DistanceContainer/Distance
@onready var coin = $PanelContainer/VBoxContainer/CoinContainer/Coin
@onready var audio_stream_player = $AudioStreamPlayer
@onready var distance_texture = $PanelContainer/VBoxContainer/DistanceContainer/DistanceTexture

var textures = {
	true : preload("res://Assets/Images/best-score.png"),
	false: preload("res://Assets/Images/distance.png")
}

func _ready():
	hide()
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)

func _on_game_start():
	hide()

func _on_game_over():
	show()
	audio_stream_player.play()
	distance_texture.texture = textures[GameManager.is_best_score()]
	distance.text = "Distance: " + str(int(GameManager.distance))
	coin.text = "coin: " + str(GameManager.coin)
	animation_player.play("popup")

func _on_texture_button_pressed():
	GameManager.start()
