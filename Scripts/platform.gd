extends Node3D

@onready var ground_bridge_surface = $bridge/ground/ground_bridge_surface

func get_aabb():
	return ground_bridge_surface.get_aabb()
