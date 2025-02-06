extends Area3D

@export var mesh: MeshInstance3D
var hologram_material = preload("res://Resources/hologram.tres")

func _ready():
	GameManager.power_activated.connect(_on_power_activate)
	GameManager.power_finished.connect(_on_power_finish)

func _on_power_activate(power: PowerData):
	activate_power.call_deferred(power)

func activate_power(power: PowerData):
	match power.name:
		"Car":
			monitoring = false
			if !mesh:
				return
			mesh.material_override = hologram_material

func _on_power_finish(power: PowerData):
	power_finish.call_deferred(power)

func power_finish(power: PowerData):
	match power.name:
		"Car":
			await get_tree().create_timer(1.0).timeout
			monitoring = true
			if mesh:
				mesh.material_override = null
			

func _on_body_entered(body, is_ground: bool = false):
	if body is Player:
		if !is_ground and (position.z < -0.5 or body.position.x != position.x):
			return
		GameManager.register_collision()

