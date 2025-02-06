extends Area3D


func _on_body_entered(body, is_ground: bool = false):
	if body is Player:
		if body.current_shape == body.SHAPE.CAR:
#			throw()
			return
		if !is_ground and (position.z < -0.5 or body.position.x != position.x):
			return
		GameManager.register_collision()

