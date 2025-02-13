extends Node3D

var powers: Array
@export var spawn_distance: int = 200
 
func _ready():
	powers = get_children()
	powers.map(func(obj): obj.hide())

func get_inactive_powers():
	return powers.filter(func(power): return !power.visible)

func set_spawn_distance():
	spawn_distance = randi_range(-200, 600) + spawn_distance
