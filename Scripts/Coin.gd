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
		play_coin_pick_animation()

func play_coin_pick_animation():
	var tween = create_tween()
	tween.parallel().tween_property(mesh, "scale", Vector3.ONE * 1.5, 0.2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mesh, "scale", Vector3.ZERO, 0.3).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(mesh, "position", Vector3(-30, 30, 30), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		mesh.scale = Vector3.ONE
		mesh.position = Vector3.ZERO
		visible = false
	)
