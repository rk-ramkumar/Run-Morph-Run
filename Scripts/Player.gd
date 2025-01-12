class_name Player extends CharacterBody3D

@onready var animation_player = $AnimationPlayer
var speed = 15
const jumpVelocity = 20.0

const lerpSpeed = 15.0
var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation_player.play("Running")

func _process(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = lerp(velocity.y, jumpVelocity, delta * lerpSpeed)
		animation_player.play("Jump")
		await animation_player.animation_finished
		animation_player.play("Running")

	move_and_slide()
