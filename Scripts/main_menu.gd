extends Control

@onready var coin = $CoinPanelContainer/CoinContainer/Coin
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite/InputMask
@onready var name_panel_container = $NamePanelContainer
@onready var line_edit = $NamePanelContainer/LineEdit
@onready var audio_stream_player = $AudioStreamPlayer
@onready var join_code_popup = $JoinCodePopup
@onready var join_line_edit = $JoinCodePopup/Panel/VBoxContainer/LineEdit
var room_id: String = ""

func _ready():
	animation_player.play("start")
	GameManager.request_home.connect(_on_request_home)
	_set_coin_label()
	audio_stream_player.play()
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
	_set_coin_label()
	set_process_input(true)
	audio_stream_player.play()

func _set_coin_label():
	coin.text = str(GameManager.total_coin)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		if sprite.get_rect().has_point(sprite.to_local(event.position)):
			audio_stream_player.stop()
			GameManager.start()
			set_process_input(false)
			hide()

func _on_line_edit_text_submitted(new_text):
	GameManager.set_player_name(new_text)

func _on_host_button_pressed():
	WebSocket.listen()
	WebSocket.create_room()

func _on_join_button_pressed():
	WebSocket.listen()
	join_code_popup.show()

func _on_line_edit_text_changed(new_text):
	room_id = new_text

func _on_join_confirm_button_pressed():
	WebSocket.join_room(room_id)
	_rest_join_popup()

func _on_join_cancel_button_pressed():
	WebSocket.stop_listen()
	_rest_join_popup()

func _rest_join_popup():
	room_id = ""
	join_line_edit.text = ""
	join_code_popup.hide()
