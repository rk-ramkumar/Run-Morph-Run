extends Area3D

@onready var animation_player = $AnimationPlayer


func _on_visibility_changed():
	if !animation_player:
		return

	if visible:
		animation_player.play("move")
	else:
		animation_player.stop()


func _on_body_entered(body):
	print(body)
