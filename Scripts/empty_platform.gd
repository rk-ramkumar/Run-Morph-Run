extends Platform

@export var mesh: MeshInstance3D
var hologram_material = preload("res://Resources/hologram.tres")
@onready var collision_shape = $MeshInstance3D/StaticBody3D/CollisionShape3D

func _ready():
	super._ready()
	collision_shape.disabled = true
	GameManager.power_activated.connect(_on_power_activate)
	GameManager.power_finished.connect(_on_power_finish)

func _on_power_activate(power: PowerData):
	activate_power.call_deferred(power)

func activate_power(power: PowerData):
	match power.name:
		"Car":
			if !mesh:
				return
			mesh.material_override = hologram_material
			collision_shape.disabled = false

func _on_power_finish(power: PowerData):
	power_finish.call_deferred(power)

func power_finish(power: PowerData):
	match power.name:
		"Car":
			if !mesh:
				return
			mesh.material_override = null
			collision_shape.disabled = true
