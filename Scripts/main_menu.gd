extends Control

@onready var coin = $CoinPanelContainer/CoinContainer/Coin
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite
@onready var name_panel_container = $NamePanelContainer
@onready var line_edit = $NamePanelContainer/LineEdit

func _ready():
	animation_player.play("start")
	GameManager.request_home.connect(_on_request_home)
	_set_coin_label()
	if GameManager.player_name.is_empty():
		line_edit.text_submitted.connect(_on_line_edit_text_submitted)
		line_edit.focus_mode = FOCUS_CLICK
		line_edit.editable = true
	else:
		line_edit.focus_mode = FOCUS_NONE
		line_edit.text = GameManager.player_name
		line_edit.editable = false

func _on_request_home():
	show()
	set_process_input(true)

func _set_coin_label():
	coin.text = str(GameManager.total_coin)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		if sprite.get_rect().has_point(sprite.to_local(event.position)):
			GameManager.start()
			set_process_input(false)
			hide()

func _on_line_edit_text_submitted(new_text):
	GameManager.set_player_name(new_text)
