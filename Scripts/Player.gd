class_name Player extends CharacterBody3D

@export var armature_scene: PackedScene

const jumpVelocity = 20.0
const lerpSpeed = 15.0

var animation_player: AnimationPlayer
var speed = 15
var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
		animation_player.play("Jump")
		await animation_player.animation_finished
		animation_player.play("Running")

	move_and_slide()
