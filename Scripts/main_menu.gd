extends Control

@onready var coin = $CoinPanelContainer/CoinContainer/Coin
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite/InputMask
@onready var name_panel_container = $NamePanelContainer
@onready var line_edit = $NamePanelContainer/LineEdit
@onready var audio_stream_player = $AudioStreamPlayer
@onready var join_code_popup = $JoinCodePopup
@onready var join_line_edit = $JoinCodePopup/Panel/VBoxContainer/LineEdit
@onready var error_label = $ErrorLabel
@onready var room_id_label = $HostPopup/RoomIDPanelContainer/RoomIdContainer/Label
@onready var host_play_button = $HostPopup/PlayButton

var room_id: String = ""
var error_text = "[center][color=red]{message}[/color][/center]"
var error_tween: Tween
var players_panels: Array

func _ready():
	animation_player.play("start")
	GameManager.request_home.connect(_on_request_home)
	WebSocket.room_created.connect(_on_room_created)
	WebSocket.error.connect(_on_error)
	WebSocket.player_joined.connect(_on_player_joined)
	_set_coin_label()
	players_panels = $HostPopup/PlayersPanelContainer/MarginContainer/GridContainer.get_children()
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

func _on_room_created(msg):
	host_play_button.show()
	animation_player.play("hostPopup")
	update_players_panel(msg)

func _on_error(msg):
	error_label.text = error_text.format(msg)
	fade_error_msg()

func fade_error_msg():
	if error_tween:
		error_tween.kill()
	error_tween = create_tween()
	error_tween.tween_property(error_label,"self_modulate:a", 0.5, 2.0)
	error_tween.tween_callback(func():
		error_tween = null
		error_label.self_modulate.a = 1.0
		error_label.text = ""
		)

func _on_player_joined(msg):
	if !WebSocket.is_host:
		host_play_button.hide()
	update_players_panel(msg)
	animation_player.play("hostPopup")

func update_players_panel(msg):
	var profiles = msg.profiles
	room_id_label.text = "room id:\n" + str(msg.room_id)
	for i in profiles.size():
		var name_label = players_panels[i].get_node("HBoxContainer/NameLabel")
		name_label.text = profiles[i].name
		name_label.show()

func _on_play_button_pressed():
	pass # Replace with function body.
