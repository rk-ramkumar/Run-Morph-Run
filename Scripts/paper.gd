extends Node3D

var player: Player
var gravity = 2.0
var is_held = false
var hold_threshold = 0.2
var hold_duration = 0.0
var signal_emited: bool = false

func _ready():
	player = get_parent()

func handle_process(delta):
	if !is_held and player.position.y > 0:
		player.position.y -= gravity * delta

func handle_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_held = true
			signal_emited = false
		else:
			is_held = false
			hold_duration = 0.0

func _physics_process(delta):
	if is_held and player.actions.can_hold:
		hold_duration += delta
		if hold_duration >= hold_threshold:
			if !signal_emited:
				player.hold_detected.emit()
				signal_emited = true
			print(player.position.y)
			if player.position.y <= 4:
				player.position.y += 5 * delta
			
