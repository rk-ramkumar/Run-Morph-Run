extends Control

@onready var animation_player = $AnimationPlayer
var gestures = {
	"left": {
		"text": "Swipe left to dodge obstacles.",
		"done": false
	},
	"right": {
		"text": "Swipe right to change lanes.",
		"done": false
	},
	"down": {
		"text": "Swipe down to slide under obstacles.",
		"done": false
	},
	"up": {
		"text": "Swipe up to jump over obstacles.",
		"done": false
	},
	"double_tap": {
		"text": "Double-tap to change shape.",
		"done": false
	},
	"hold": {
		"text": "Hold to glide as a paper shape and avoid falling.",
		"done": false
	}
}

var arrow_teture = preload("res://Assets/Images/right-arrow.png")
var double_tap_texture = preload("res://Assets/Images/double-tap.png")
@onready var texture_rect = $TextureRect
@onready var label = $Label

var player: Player
var complete_list:Array = []
var keys = gestures.keys()
var actions = ["move_left", "move_right", "move_down", "move_up", "double_tap", "hold_detected"]
var restart = false

func _ready():
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	set_physics_process(false)
	change_actions()
	player.jumpVelocity = 150.0
	player.speed = 30.0
	hide()
	await get_tree().create_timer(0.8, false).timeout
	show()
	set_physics_process(true)
	_connect_signal()

func _connect_signal():
	for action in actions:
		if not player[action].is_connected(_mark_done):
			player[action].connect(_mark_done.bind(action))
	
func _physics_process(_delta):
	if keys.is_empty():
		player.speed = 35.0
		player.jumpVelocity = 25.0
		GameManager.set_training(false)
		set_physics_process(false)
		change_actions(true)
		hide()
		return

	var gesture = keys.front()
	if !complete_list.has(gesture):
		player.actions["can_"+gesture] = true
		texture_rect.rotation_degrees = 0
		match gesture:
			"up":
				texture_rect.rotation_degrees = 90
			"down":
				texture_rect.rotation_degrees = 90
			"double_tap":
				texture_rect.texture = double_tap_texture
			"hold":
				texture_rect.texture = double_tap_texture
			_:
				texture_rect.texture = arrow_teture
		label.text = gestures[gesture].text
		animation_player.play(gesture)
		complete_list.append(gesture)
		Engine.time_scale = 0.2
	
	if gestures[gesture].done:
		keys.pop_front()
		Engine.time_scale = 1.0
		set_physics_process(false)
		hide()
		await get_tree().create_timer(1, false).timeout
		if !GameManager.is_game_over and !restart:
			set_physics_process(true)
			if !keys.is_empty():
				show()

func _mark_done(event):
	var gesture = keys.front()
	player[event].disconnect(_mark_done.bind(event))
	gestures[gesture].done = true
	player.actions["can_"+gesture] = false

func change_actions(value = false):
	for action in player.actions:
		player.actions[action] = value

func _on_game_over():
	Engine.time_scale = 1.0
	player.speed = 35.0
	player.jumpVelocity = 25.0
	hide()
	set_physics_process(false)

func _on_game_start():
	if GameManager.has_training:
		set_physics_process(false)
		change_actions()
		player.speed = 30.0
		player.jumpVelocity = 150.0
		keys = gestures.keys()
		complete_list = []
		for key in gestures:
			gestures[key].done = false
		restart = true
		await get_tree().create_timer(0.8, false).timeout
		show()
		set_physics_process(true)
		_connect_signal()
		restart = false
