class_name Player extends CharacterBody3D

@export var human_scene: PackedScene
@export var paper_scene: PackedScene
@export var car_scene: PackedScene
@export var jumpVelocity = 25.0

@onready var leg_hitbox = $LegHitbox
@onready var head_hitbox = $HeadHitbox
@onready var paper_hitbox = $PaperHitbox
@onready var car_hitbox = $CarHitbox
@onready var power_timer_indicator = $PowerTimerIndicator

signal move_left
signal move_right
signal move_up
signal move_down
signal double_tap
signal hold_detected
signal lane_changed(x_pos: float)

const lerpSpeed = 25.0

enum STATE {
	RUNNING,
	SLIDING,
	FALLING,
	LANDING
}
enum SHAPE {
	HUMAN,
	PAPER,
	CAR
}
var actions: Dictionary = {
	"can_left": true,
	"can_right": true,
	"can_down": true,
	"can_up": true,
	"can_double_tap": true,
	"can_hold": true,
}
var human_anim_player: AnimationPlayer
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
var current_speed: float
var timers: Array = []

func _ready():
	if !human_scene:
		print("Human armature is empty")
		set_physics_process(false)
		return
	_initialize_armatures()
	human_anim_player.play("Running")
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_start.connect(_on_game_start)
	GameManager.game_restart.connect(_on_game_start)
	GameManager.game_pause.connect(_on_game_pause)
	GameManager.game_resume.connect(_on_game_resume)
	GameManager.request_home.connect(_on_request_home)
	GameManager.power_activated.connect(_on_power_activated)
	set_physics_process(false)
	set_process_unhandled_input(false)

func _initialize_armatures():
	var armature = human_scene.instantiate()
	mesh[SHAPE.HUMAN] = armature
	human_anim_player = armature.get_node("AnimationPlayer")

	var paper = paper_scene.instantiate()
	mesh[SHAPE.PAPER] = paper

	var car = car_scene.instantiate()
	mesh[SHAPE.CAR] = car

	add_child(armature)
	add_child(paper)
	add_child(car)
	paper.hide()
	car.hide()
	
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
				human_anim_player.play("FallingIdle", 0.2)
		
			if velocity.y < -3 and current_state == STATE.FALLING:
				current_state = STATE.LANDING
				play_animation("JumpingDown", 1,  0.2)
			# Enable collision when player land
			if velocity.y < -3 and leg_hitbox.disabled:
				leg_hitbox.disabled = false
				if current_state != STATE.SLIDING:
					current_state = STATE.RUNNING
			
			if human_anim_player.current_animation != "Slide" and head_hitbox.disabled:
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
		match current_shape:
			SHAPE.HUMAN:
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
	human_anim_player.play("JumpingUp", 0.2)
	human_anim_player.queue("FallingIdle")

func play_animation(anim_name, anim_speed: float = 1, blend: float = -1):
	human_anim_player.play(anim_name, blend, anim_speed)
	human_anim_player.clear_queue()
	human_anim_player.queue("Running")

func _change_mesh():
	match current_shape:
		SHAPE.HUMAN:
			head_hitbox.disabled = false
			leg_hitbox.disabled = false
			paper_hitbox.disabled = true
			car_hitbox.disabled = true
			mesh[SHAPE.HUMAN].show()
			mesh[SHAPE.PAPER].hide()
			mesh[SHAPE.CAR].hide()
		SHAPE.PAPER:
			paper_hitbox.disabled = false
			head_hitbox.disabled = true
			leg_hitbox.disabled = true
			car_hitbox.disabled = true
			mesh[SHAPE.PAPER].show()
			mesh[SHAPE.HUMAN].hide()
			mesh[SHAPE.CAR].hide()
		SHAPE.CAR:
			car_hitbox.disabled = false
			paper_hitbox.disabled = true
			head_hitbox.disabled = true
			leg_hitbox.disabled = true
			mesh[SHAPE.CAR].show()
			mesh[SHAPE.PAPER].hide()
			mesh[SHAPE.HUMAN].hide()


func _on_game_over():
	if current_state == STATE.FALLING:
		position.y = 0
	human_anim_player.play("Stunned")
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
	paper_hitbox.disabled = true
	current_state = STATE.RUNNING
	current_shape = SHAPE.HUMAN
	human_anim_player.play("Running")
	for action in actions:
		actions[action] = true

func _on_game_pause():
	human_anim_player.play("BreathingIdle", 0.2)
	set_physics_process(false)
	set_process_unhandled_input(false)
	swipe_start_position = Vector2.ZERO
	swipe_end_position = Vector2.ZERO

func _on_game_resume():
	human_anim_player.play("Running", 0.2)
	set_process_unhandled_input(true)
	set_physics_process(true)

func _on_request_home():
	set_physics_process(false)
	set_process_unhandled_input(false)

func _on_power_activated(power: PowerData):
	activate_power.call_deferred(power)

func activate_power(power: PowerData):
	if !timers.is_empty():
		var has_active_timer = timers.any(func(timer: Timer): 
			if timer.get_meta("power").name == power.name:
				timer.set_wait_time(timer.time_left + power.active_time)
				timer.start()
				power_timer_indicator.add_time(power.active_time)
				return true
			return false
			)
		if has_active_timer:
			return

	var timer = Timer.new()
	timer.one_shot = true
	timer.set_meta("power", power)
	timer.timeout.connect(_on_power_timer_timeout.bind(timer, power))
	add_child(timer)
	timer.start(power.active_time)
	timers.append(timer)
	match power.name:
		"Car":
			current_shape = SHAPE.CAR
			current_speed = speed
			speed = 150.0
			actions.can_double_tap = false
			power_timer_indicator.start(power.active_time)

func _on_power_finished(power: PowerData):
	match power.name:
		"Car":
			power_timer_indicator.stop()
			current_shape = SHAPE.HUMAN
			actions.can_double_tap = true
			speed = current_speed

func _on_power_timer_timeout(timer: Timer, power: PowerData):
	_on_power_finished.call_deferred(power)
	remove_child(timer)
	timers.erase(timer)
	await get_tree().create_timer(1.5).timeout
	GameManager.power_finished.emit(power)
