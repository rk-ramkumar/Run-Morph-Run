class_name Coin extends Area3D

@onready var mesh = $Mesh
@onready var audio_stream_player = $AudioStreamPlayer3D

var rotation_deg: float = 0.0

func _ready():
	rotation_deg = randf_range(45, 90)

func _process(delta):
	_rotate(delta)

func _rotate(delta):
	mesh.rotation_degrees.y -= (rotation_deg * delta) 

func _on_body_entered(_body):
	if visible:
		audio_stream_player.play()
		GameManager.increase_coins()
		var tween = create_tween()
		tween.parallel().tween_property(mesh, "scale", Vector3.ZERO, 0.5)
		tween.parallel().tween_property(mesh, "position", Vector3(-5, 30, 0), 0.5)
		tween.tween_callback(func(): 
			mesh.scale = Vector3.ONE
			mesh.position = Vector3.ZERO
			visible = false
			)
