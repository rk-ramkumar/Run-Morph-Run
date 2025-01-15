class_name Player extends CharacterBody3D

@export var armature_scene: PackedScene

@onready var collision_shape = $CollisionShape3D

const jumpVelocity = 20.0
const lerpSpeed = 15.0

var animation_player: AnimationPlayer
var speed = 15
var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var swipe_start_position: Vector2 = Vector2.ZERO
var swipe_end_position: Vector2 = Vector2.ZERO
var min_swipe_distance: float = 50.0

func _ready():
	if !armature_scene:
		print("Armature is empty")
		set_physics_process(false)
		return
	var armature = armature_scene.instantiate()
	add_child(armature)
	animation_player = armature.get_node("AnimationPlayer")
	animation_player.play("Running")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = lerp(velocity.y, jumpVelocity, delta * lerpSpeed)
		collision_shape.position.y += 1
		animation_player.play("Jump")
		await animation_player.animation_finished
		animation_player.play("Running")
		collision_shape.position.y -= 1

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
			print("Swiped Right")
			_move_right()
		else:
			print("Swiped Left")
			_move_left()
	else:
		# Vertical swipe
		if swipe_vector.y > 0:
			print("Swiped Down")
			_move_down()
		else:
			print("Swiped Up")
			_move_up()

func _move_right():
	pass

func _move_left():
	pass

func _move_down():
	pass

func _move_up():
	pass
