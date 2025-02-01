extends Node3D

var powers: Array

func _ready():
	powers = get_children()
	powers.map(func(obj): obj.hide())
