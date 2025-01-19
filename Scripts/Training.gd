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

func _ready():
	set_physics_process(false)
	hide()

	await get_tree().create_timer(1).timeout
	show()
	set_physics_process(true)
	player.move_left.connect(_on_move_left)
	player.move_right.connect(_on_move_right)
	player.move_down.connect(_on_move_down)
	player.move_up.connect(_on_move_up)
	player.double_tap.connect(_on_double_tap)
	player.hold_detected.connect(_on_hold_detected)

func _physics_process(_delta):
	if keys.is_empty():
		set_physics_process(false)
		hide()
		queue_free()
		return

	var gesture = keys.front()
	if !complete_list.has(gesture):
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
		Engine.time_scale = 0.8 if gesture == "hold" else 0.2
	
	if gestures[gesture].done:
		keys.pop_front()
		Engine.time_scale = 1.0

func _on_move_left():
	_mark_done(1)
	
func _on_move_right():
	_mark_done(2)

func _on_move_down():
	_mark_done(3)
	
func _on_move_up():
	_mark_done(4)

func _on_double_tap():
	_mark_done(5)

func _on_hold_detected():
	_mark_done(6)

func _mark_done(index):
	var gestures_keys = gestures.keys()

	for i in index:
		gestures[gestures_keys[i]].done = true
