class_name Coin extends Area3D

@onready var mesh = $Mesh

var rotation_deg: float = 0.0

func _ready():
	rotation_deg = randf_range(45, 90)

func _process(delta):
	_rotate(delta)

func _rotate(delta):
	mesh.rotation_degrees.y -= (rotation_deg * delta) 


func _on_body_entered(_body):
	GameManager.increase_coins()
