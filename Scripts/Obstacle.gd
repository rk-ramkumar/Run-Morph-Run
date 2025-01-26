extends Area3D


func _on_body_entered(body):
	if body is Player:
		if position.z < -0.5 or body.position.x != position.x:
			return
		GameManager.register_collision()
