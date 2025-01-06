class_name Player extends Node3D

@onready var animation_player = $AnimationPlayer
var speed = 15

func _ready():
	animation_player.play("Running")

func _process(_delta):
	pass
