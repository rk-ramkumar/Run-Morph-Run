class_name Spawner extends Node

@export var spawn_pool_size: int = 20
@export var spawn_interval: float = 3.0
@export var spawn_distance: float = 100.0
@export var player: Player
@export var object_scene: PackedScene
@export var spawn_interval_limit: Dictionary = {
	"min": 1.0,
	"max": 5.0
}
@export var lanes: Array = [-2.5, 0, 2.5]

var pool: Array = []
var spawn_timer: float = 0.0

func _ready():
	_add_object()
	randomize()

func _add_object(amount = spawn_pool_size):
	for _i in amount:
		var object = object_scene.instantiate()
		_disable_object(object)
		add_child(object)
		pool.append(object)

func _process(delta):
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0.0
		spawn_interval = randf_range(spawn_interval_limit.min, spawn_interval_limit.max)
		_spawn_object()
	_move_active_object(delta)

func _spawn_object():
	pass

func _move_active_object(delta):
	for object in _get_active_objects():
		object.position.z -=  player.speed * delta
		_recycle_object(object)

func _get_active_objects():
	return pool.filter(func(object): return object.visible)

func _get_inactive_objects(amount: int):
	var inactive_objects = pool.filter(func(object): return !object.visible)
	if pool.size() < 25 and inactive_objects.size() < amount:
		_add_object(amount - inactive_objects.size())
		inactive_objects = pool.filter(func(object): return !object.visible)
	return inactive_objects.slice(0, min(amount, inactive_objects.size()))

func _recycle_object(object):
	if object.position.z < -5:
		_disable_object(object)

func _disable_object(object):
	object.hide()
	object.position = Vector3(0, 0, -20)
