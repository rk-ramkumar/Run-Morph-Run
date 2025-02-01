class_name Platform extends Node3D

@export var ground_surface: MeshInstance3D
@export var custom_size: Vector3 = Vector3.ZERO
@export var has_custom_size: bool = false
@export var collision: CollisionShape3D

func _ready():
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed():
	if collision == null:
		return
	collision.disabled = !visible

func get_size():
	if has_custom_size:
		return custom_size
	return ground_surface.get_aabb().size
