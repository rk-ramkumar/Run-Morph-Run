extends Area3D


func _on_body_entered(_body):
	GameManager.register_collision()
