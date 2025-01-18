class_name Platform extends Node3D

@export var ground_surface: MeshInstance3D
@export var custom_size: Vector3 = Vector3.ZERO
@export var has_custom_size: bool = false

func get_size():
	if has_custom_size:
		return custom_size
	return ground_surface.get_aabb().size
