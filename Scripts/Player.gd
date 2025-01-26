class_name Player extends CharacterBody3D

@export var human_scene: PackedScene
@export var paper_scene: PackedScene

@onready var leg_hitbox = $LegHitbox
@onready var head_hitbox = $HeadHitbox
@onready var paper_hitbox = $PaperHitbox

signal move_left
signal move_right
signal move_up
signal move_down
signal double_tap
signal hold_detected
signal lane_changed(x_pos: float)

const jumpVelocity = 25.0
const lerpSpeed = 25.0

enum STATE {
	RUNNING,
	SLIDING,
	FALLING,
	LANDING
}
enum SHAPE {
	HUMAN,
	PAPER
}
var actions: Dictionary = {
	"can_left": true,
	"can_right": true,
	"can_down": true,
	"can_up": true,
	"can_double_tap": true,
	"can_hold": true,
}
var animation_player: AnimationPlayer
var speed: float = 35.0
var max_speed_kmh: float = 100.0          # Maximum speed limit in km/h
var speed_increase_rate: float = 0.1    # Speed increase per second (km/h)
var direction = Vector3.ZERO
var gravity = 25.5
var swipe_start_position: Vector2 = Vector2.ZERO
var swipe_end_position: Vector2 = Vector2.ZERO
var min_swipe_distance: float = 50.0
var current_state: STATE = STATE.RUNNING
var lane_offset: float = 3.5
var slide_speed_penalty : float = 0.0
var current_shape : SHAPE = SHAPE.HUMAN:
	set(new_shape):
		current_shape = new_shape
		_change_mesh()
var mesh: Dictionary
var is_held = false
var signal_emited: bool = false

func _ready():
	if !human_scene:
		print("Human armature is empty")
		set_physics_process(false)
		return
	var armature = human_scene.instantiate()
	mesh[SHAPE.HUMAN] = armature
	var paper = paper_scene.instantiate()
	mesh[SHAPE.PAPER] = paper
	add_child(armature)
	add_child(paper)
	paper.hide()
	animation_player = armature.get_node("AnimationPlayer")
	animation_player.play("Running")
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	GameManager.game_pause.connect(_on_game_pause)
	GameManager.game_resume.connect(_on_game_resume)
	GameManager.request_home.connect(_on_request_home)
	set_physics_process(false)
	set_process_unhandled_input(false)

func _physics_process(delta):
	_increase_speed(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match current_shape:
		SHAPE.HUMAN:
			if not is_on_floor() and (
				current_state not in [STATE.SLIDING, STATE.FALLING, STATE.LANDING]
				):
				current_state = STATE.FALLING
				animation_player.play("FallingIdle", 0.2)
		
			if velocity.y < -3 and current_state == STATE.FALLING:
				current_state = STATE.LANDING
				play_animation("JumpingDown", 1,  0.2)
			# Enable collision when player land
			if velocity.y < -3 and leg_hitbox.disabled:
				leg_hitbox.disabled = false
				if current_state != STATE.SLIDING:
					current_state = STATE.RUNNING
			
			if animation_player.current_animation != "Slide" and head_hitbox.disabled:
#				speed += slide_speed_penalty 
				head_hitbox.disabled = false
				current_state = STATE.RUNNING

			# Handle Jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				_move_up()

		SHAPE.PAPER:
			if is_held: # Handle Paper movement
				if !signal_emited:
					hold_detected.emit()
					signal_emited = true
				if !(position.y > 4):
					velocity.y = 250 * delta
 
	move_and_slide()

func _increase_speed(delta):
	if speed < max_speed_kmh:
		speed += speed_increase_rate * delta  # Gradual increase

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if actions.can_double_tap and event.double_tap:
			double_tap.emit()
			current_shape = SHAPE.PAPER if current_shape == SHAPE.HUMAN else SHAPE.HUMAN

		elif event.is_pressed():
			swipe_start_position = event.position
			is_held = true
			signal_emited = false
		else:
			is_held = false
			swipe_end_position = event.position
			_handle_movement()

func _handle_movement():
	var distance = swipe_start_position.distance_to(swipe_end_position)
	var swipe_vector = swipe_end_position - swipe_start_position

	if distance < min_swipe_distance:
		return

	if abs(swipe_vector.x) > abs(swipe_vector.y):
	# Horizontal swipe
		if swipe_vector.x > 0:
			_move_right()
		else:
			_move_left()
	else:
		if current_shape == SHAPE.PAPER:
			return
		# Vertical swipe
		if swipe_vector.y > 0:
			_move_down()
		else:
			_move_up()

func _move_right():
	if !actions.can_right:
		return
	move_right.emit()
	var new_pos = clamp(position.x - lane_offset, -lane_offset, 0)
	position.x = new_pos
	lane_changed.emit(new_pos)

func _move_left():
	if !actions.can_left:
		return
	move_left.emit()
	var new_pos = clamp(position.x + lane_offset, 0, lane_offset)
	position.x = new_pos
	lane_changed.emit(new_pos)

func _move_down():
	if !actions.can_down:
		return
	move_down.emit()
	if current_state == STATE.FALLING:
		velocity.y -= 30.0
	current_state = STATE.SLIDING
	head_hitbox.disabled = true
#	slide_speed_penalty = speed * 0.2
#	speed -= slide_speed_penalty  # 20% speed reduction during slide
	play_animation("Slide", 1.8)

func _move_up():
	if not is_on_floor() or !actions.can_up:
		return
	move_up.emit()
	current_state = STATE.FALLING
	velocity.y = lerp(velocity.y, jumpVelocity, get_physics_process_delta_time() * lerpSpeed)
	leg_hitbox.disabled = true
#	play_animation("Jump", 1, 0.2)
	animation_player.play("JumpingUp", 0.2)
	animation_player.queue("FallingIdle")

func play_animation(anim_name, anim_speed: float = 1, blend: float = -1):
	animation_player.play(anim_name, blend, anim_speed)
	animation_player.clear_queue()
	animation_player.queue("Running")

func _change_mesh():
	match current_shape:
		SHAPE.HUMAN:
			head_hitbox.disabled = false
			leg_hitbox.disabled = false
			paper_hitbox.disabled = true
			mesh[SHAPE.HUMAN].show()
			mesh[SHAPE.PAPER].hide()
		SHAPE.PAPER:
			head_hitbox.disabled = true
			leg_hitbox.disabled = true
			paper_hitbox.disabled = false
			mesh[SHAPE.PAPER].show()
			mesh[SHAPE.HUMAN].hide()

func _on_game_over():
	position.y = 0
	animation_player.play("Stunned")
	set_physics_process(false)
	set_process_unhandled_input(false)

func _on_game_start():
	swipe_start_position = Vector2.ZERO
	swipe_end_position = Vector2.ZERO
	set_physics_process(true)
	set_process_unhandled_input(true)
	position = Vector3.ZERO
	speed = 35.0
	velocity.y = 0.0
	current_state = STATE.RUNNING
	current_shape = SHAPE.HUMAN
	animation_player.play("Running")
	for action in actions:
		actions[action] = true

func _on_game_pause():
	animation_player.play("BreathingIdle", 0.2)
	set_physics_process(false)
	set_process_unhandled_input(false)
	swipe_start_position = Vector2.ZERO
	swipe_end_position = Vector2.ZERO

func _on_game_resume():
	animation_player.play("Running", 0.2)
	set_process_unhandled_input(true)
	set_physics_process(true)

func _on_request_home():
	set_physics_process(false)
	set_process_unhandled_input(false)
