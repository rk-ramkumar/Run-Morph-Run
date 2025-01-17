class_name Player extends CharacterBody3D

@export var armature_scene: PackedScene

@onready var leg_hitbox = $LegHitbox
@onready var head_hitbox = $HeadHitbox

const jumpVelocity = 20.0
const lerpSpeed = 15.0

enum STATE {
	RUNNING,
	SLIDING,
	JUMPING
}
var animation_player: AnimationPlayer
var speed = 15
var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var swipe_start_position: Vector2 = Vector2.ZERO
var swipe_end_position: Vector2 = Vector2.ZERO
var min_swipe_distance: float = 50.0
var current_state: STATE = STATE.RUNNING
var lane_offset: float

func _ready():
	if !armature_scene:
		print("Armature is empty")
		set_physics_process(false)
		return
	var armature = armature_scene.instantiate()
	add_child(armature)
	animation_player = armature.get_node("AnimationPlayer")
	animation_player.play("Running")
	lane_offset = get_parent().lane_offset

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Enable collision when player land
	if is_on_floor() and leg_hitbox.disabled:
		leg_hitbox.disabled = false
		current_state = STATE.RUNNING
	
	if animation_player.current_animation == "Running" and head_hitbox.disabled:
		head_hitbox.disabled = false
		current_state = STATE.RUNNING

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_move_up()

	move_and_slide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_start_position = event.position
		else:
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
		# Vertical swipe
		if swipe_vector.y > 0:
			_move_down()
		else:
			_move_up()

func _move_right():
	if current_state == STATE.SLIDING:
		return
	var new_pos = clamp(position.x - lane_offset, -lane_offset, 0)
	position.x = new_pos

func _move_left():
	if current_state == STATE.SLIDING:
		return
	var new_pos = position.x + lane_offset
	position.x = clamp(new_pos, 0, lane_offset)

func _move_down():
	if not is_on_floor():
		return
	current_state = STATE.SLIDING
	head_hitbox.disabled = true
	play_animation("Slide")

func _move_up():
	if not is_on_floor():
		return
	current_state = STATE.JUMPING
	velocity.y = lerp(velocity.y, jumpVelocity, get_physics_process_delta_time() * lerpSpeed)
	leg_hitbox.disabled = true
	play_animation("Jump")

func play_animation(anim_name):
	animation_player.play(anim_name)
	animation_player.clear_queue()
	animation_player.queue("Running")
	
