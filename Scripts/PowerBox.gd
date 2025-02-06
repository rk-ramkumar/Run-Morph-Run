extends Area3D

@onready var animation_player = $AnimationPlayer
@export var power: PowerData

func _on_visibility_changed():
	if !animation_player:
		return

	if visible:
		animation_player.play("move")
	else:
		animation_player.stop()

func _on_body_entered(_body):
	GameManager.power_activated.emit(power)
